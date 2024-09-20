(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024 Mathieu Barbin <mathieu.barbin@gmail.com>               *)
(*                                                                             *)
(*  This file is part of Vcs.                                                  *)
(*                                                                             *)
(*  Vcs is free software; you can redistribute it and/or modify it under       *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Vcs is distributed in the hope that it will be useful, but WITHOUT ANY     *)
(*  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*  the file `NOTICE.md` at the root of this repository for more details.      *)
(*                                                                             *)
(*  You should have received a copy of the GNU Lesser General Public License   *)
(*  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*******************************************************************************)

(* The commands below are sorted alphabetically. Their name must be derived from
   the name the associated function has in the [V.S] interface, prepending the
   suffix "_cmd". *)

let add_cmd =
  Command.make
    ~summary:"add a file to the index"
    (let%map_open.Command config = Vcs_arg.Config.arg
     and path = Vcs_arg.pos_path_in_repo ~pos:0 ~doc:"file to add" in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root; context } =
       Vcs_arg.initialize ~env ~config
     in
     let path = Vcs_arg.resolve ~context path in
     Vcs.add vcs ~repo_root ~path;
     ())
;;

let commit_cmd =
  Command.make
    ~summary:"commit a file"
    (let%map_open.Command config = Vcs_arg.Config.arg
     and commit_message = Vcs_arg.commit_message
     and quiet = Vcs_arg.quiet in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root; context = _ } =
       Vcs_arg.initialize ~env ~config
     in
     let rev = Vcs.commit vcs ~repo_root ~commit_message in
     if not quiet then Eio_writer.print_sexp ~env [%sexp (rev : Vcs.Rev.t)];
     ())
;;

let current_branch_cmd =
  Command.make
    ~summary:"current branch"
    (let%map_open.Command config = Vcs_arg.Config.arg in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root; context = _ } =
       Vcs_arg.initialize ~env ~config
     in
     let branch = Vcs.current_branch vcs ~repo_root in
     Eio_writer.print_sexp ~env [%sexp (branch : Vcs.Branch_name.t)];
     ())
;;

let current_revision_cmd =
  Command.make
    ~summary:"revision of HEAD"
    (let%map_open.Command config = Vcs_arg.Config.arg in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root; context = _ } =
       Vcs_arg.initialize ~env ~config
     in
     let rev = Vcs.current_revision vcs ~repo_root in
     Eio_writer.print_sexp ~env [%sexp (rev : Vcs.Rev.t)];
     ())
;;

let git_cmd =
  Command.make
    ~summary:"run the git cli"
    (let%map_open.Command config = Vcs_arg.Config.arg
     and args =
       Arg.pos_all Param.string ~docv:"ARG" ~doc:"pass the remaining args to git"
     in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root; context = _ } =
       Vcs_arg.initialize ~env ~config
     in
     let { Vcs.Git.Output.exit_code; stdout; stderr } =
       Vcs.git vcs ~repo_root ~args ~f:Fn.id
     in
     Eio_writer.print_string ~env stdout;
     Eio_writer.prerr_string ~env stderr;
     if exit_code <> 0 then Stdlib.exit exit_code)
;;

let init_cmd =
  Command.make
    ~summary:"initialize a new repository"
    (let%map_open.Command config = Vcs_arg.Config.arg
     and path = Vcs_arg.pos_path ~pos:0 ~doc:"where to initialize the repository"
     and quiet = Vcs_arg.quiet in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root = _; context } =
       Vcs_arg.initialize ~env ~config
     in
     let path = Vcs_arg.resolve path ~context in
     let repo_root = Vcs.init vcs ~path in
     if not quiet
     then Eio_writer.print_sexp ~env [%sexp (repo_root : Vcs.Repo_root.t)] [@coverage off];
     ())
;;

let load_file_cmd =
  Command.make
    ~summary:"print a file from the filesystem (aka cat)"
    (let%map_open.Command config = Vcs_arg.Config.arg
     and path = Vcs_arg.pos_path ~pos:0 ~doc:"file to load" in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root = _; context } =
       Vcs_arg.initialize ~env ~config
     in
     let path = Vcs_arg.resolve path ~context in
     let contents = Vcs.load_file vcs ~path in
     Eio_writer.print_string ~env (contents :> string);
     ())
;;

let ls_files_cmd =
  Command.make
    ~summary:"list file"
    (let%map_open.Command config = Vcs_arg.Config.arg
     and below = Vcs_arg.below_path_in_repo in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root; context } =
       Vcs_arg.initialize ~env ~config
     in
     let below = Vcs_arg.resolve below ~context in
     let below = Option.value below ~default:Vcs.Path_in_repo.root in
     let files = Vcs.ls_files vcs ~repo_root ~below in
     Eio_writer.with_flow (Eio.Stdenv.stdout env) (fun w ->
       List.iter files ~f:(fun file ->
         Eio_writer.write_line w (Vcs.Path_in_repo.to_string file)));
     ())
;;

let log_cmd =
  Command.make
    ~summary:"show the log of current repo"
    (let%map_open.Command config = Vcs_arg.Config.arg in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root; context = _ } =
       Vcs_arg.initialize ~env ~config
     in
     let log = Vcs.log vcs ~repo_root in
     Eio_writer.print_sexp ~env [%sexp (log : Vcs.Log.t)];
     ())
;;

let name_status_cmd =
  Command.make
    ~summary:"show a summary of the diff between 2 revs"
    (let%map_open.Command config = Vcs_arg.Config.arg
     and src = Vcs_arg.pos_rev ~pos:0 ~doc:"base revision"
     and dst = Vcs_arg.pos_rev ~pos:1 ~doc:"tip revision" in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root; context = _ } =
       Vcs_arg.initialize ~env ~config
     in
     let name_status = Vcs.name_status vcs ~repo_root ~changed:(Between { src; dst }) in
     Eio_writer.print_sexp ~env [%sexp (name_status : Vcs.Name_status.t)];
     ())
;;

let num_status_cmd =
  Command.make
    ~summary:"show a summary of the number of lines of diff between 2 revs"
    (let%map_open.Command config = Vcs_arg.Config.arg
     and src = Vcs_arg.pos_rev ~pos:0 ~doc:"base revision"
     and dst = Vcs_arg.pos_rev ~pos:1 ~doc:"tip revision" in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root; context = _ } =
       Vcs_arg.initialize ~env ~config
     in
     let num_status = Vcs.num_status vcs ~repo_root ~changed:(Between { src; dst }) in
     Eio_writer.print_sexp ~env [%sexp (num_status : Vcs.Num_status.t)];
     ())
;;

let rename_current_branch_cmd =
  Command.make
    ~summary:"move/rename a branch to a new name"
    (let%map_open.Command config = Vcs_arg.Config.arg
     and branch_name = Vcs_arg.pos_branch_name ~pos:0 ~doc:"new name to rename to" in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root; context = _ } =
       Vcs_arg.initialize ~env ~config
     in
     Vcs.rename_current_branch vcs ~repo_root ~to_:branch_name;
     ())
;;

let refs_cmd =
  Command.make
    ~summary:"show the refs of current repo"
    (let%map_open.Command config = Vcs_arg.Config.arg in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root; context = _ } =
       Vcs_arg.initialize ~env ~config
     in
     let refs = Vcs.refs vcs ~repo_root in
     Eio_writer.print_sexp ~env [%sexp (refs : Vcs.Refs.t)];
     ())
;;

let save_file_cmd =
  Command.make
    ~summary:"save stdin to a file from the filesystem (aka tee)"
    (let%map_open.Command config = Vcs_arg.Config.arg
     and path = Vcs_arg.pos_path ~pos:0 ~doc:"file to save the contents to" in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root = _; context } =
       Vcs_arg.initialize ~env ~config
     in
     let path = Vcs_arg.resolve path ~context in
     let file_contents =
       Eio.Buf_read.parse_exn
         Eio.Buf_read.take_all
         (Eio.Stdenv.stdin env)
         ~max_size:Int.max_value
       |> Vcs.File_contents.create
     in
     Vcs.save_file vcs ~path ~file_contents;
     ())
;;

let set_user_config_cmd =
  Command.make
    ~summary:"set the user config"
    (let%map_open.Command config = Vcs_arg.Config.arg
     and user_name = Vcs_arg.user_name
     and user_email = Vcs_arg.user_email in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root; context = _ } =
       Vcs_arg.initialize ~env ~config
     in
     Vcs.set_user_name vcs ~repo_root ~user_name;
     Vcs.set_user_email vcs ~repo_root ~user_email;
     ())
;;

let show_file_at_rev_cmd =
  Command.make
    ~summary:"show the contents of file at a given revision"
    (let%map_open.Command config = Vcs_arg.Config.arg
     and rev = Vcs_arg.rev ~doc:"revision to show"
     and path = Vcs_arg.pos_path_in_repo ~pos:0 ~doc:"path to file" in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root; context } =
       Vcs_arg.initialize ~env ~config
     in
     let path = Vcs_arg.resolve path ~context in
     let result = Vcs.show_file_at_rev vcs ~repo_root ~rev ~path in
     (match result with
      | `Present contents -> Eio_writer.print_string ~env (contents :> string)
      | `Absent ->
        Eio_writer.eprintf
          ~env
          "Path '%s' does not exist in '%s'"
          (Vcs.Path_in_repo.to_string path)
          (Vcs.Rev.to_string rev));
     ())
;;

let graph_cmd =
  Command.make
    ~summary:"compute graph of current repo"
    (let%map_open.Command config = Vcs_arg.Config.arg in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root; context = _ } =
       Vcs_arg.initialize ~env ~config
     in
     let graph = Vcs.graph vcs ~repo_root in
     Eio_writer.print_sexp ~env [%sexp (Vcs.Graph.summary graph : Vcs.Graph.Summary.t)];
     ())
;;

(* The following section expands the cli to help with test coverage. *)

let branch_revision_cmd =
  Command.make
    ~summary:"revision of a branch"
    (let%map_open.Command config = Vcs_arg.Config.arg
     and branch_name = Vcs_arg.pos_branch_name_opt ~pos:0 ~doc:"which branch" in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root; context = _ } =
       Vcs_arg.initialize ~env ~config
     in
     let branch_name =
       match branch_name with
       | Some branch_name -> branch_name
       | None -> Vcs.current_branch vcs ~repo_root
     in
     let rev =
       let refs = Vcs.refs vcs ~repo_root |> Vcs.Refs.to_map in
       match Map.find refs (Local_branch { branch_name }) with
       | Some rev -> rev
       | None ->
         (* This line is covered in tests, but we need to disable coverage
            reporting here. The reason is that bisect_ppx inserts an unvisitable
            coverage point at the out-edge of this raising call, which would
            otherwise result in a false negative in our test coverage. *)
         Vcs.raise_s
           "Branch not found"
           [%sexp { branch_name : Vcs.Branch_name.t }] [@coverage off]
     in
     Eio_writer.print_sexp ~env [%sexp (rev : Vcs.Rev.t)];
     ())
;;

let greatest_common_ancestors_cmd =
  Command.make
    ~summary:"print greatest common ancestors of revisions"
    (let%map_open.Command config = Vcs_arg.Config.arg
     and revs = Vcs_arg.pos_revs ~doc:"all revisions that must descend from the gcas" in
     Eio_main.run
     @@ fun env ->
     let { Vcs_arg.Initialized.vcs; repo_root; context = _ } =
       Vcs_arg.initialize ~env ~config
     in
     let graph = Vcs.graph vcs ~repo_root in
     let nodes =
       List.map revs ~f:(fun rev ->
         match Vcs.Graph.find_rev graph ~rev with
         | Some node -> node
         | None -> Vcs.raise_s "Rev not found" [%sexp { rev : Vcs.Rev.t }])
     in
     let gca =
       Vcs.Graph.greatest_common_ancestors graph nodes
       |> List.map ~f:(fun node -> Vcs.Graph.rev graph node)
     in
     Eio_writer.print_sexp ~env [%sexp (gca : Vcs.Rev.t list)];
     ())
;;

let more_tests_cmd =
  Command.group
    ~summary:"more tests combining vcs functions"
    [ "branch-revision", branch_revision_cmd; "gca", greatest_common_ancestors_cmd ]
;;

let main =
  Command.group
    ~summary:"call a command from the vcs interface"
    ~readme:(fun () ->
      {|
This is an executable to test the Version Control System (vcs) library.

We expect a 1:1 mapping between the function exposed in the [Vcs.S] and the
sub commands exposed here, plus additional functionality in [more-tests].
|})
    [ "add", add_cmd
    ; "commit", commit_cmd
    ; "current-branch", current_branch_cmd
    ; "current-revision", current_revision_cmd
    ; "git", git_cmd
    ; "init", init_cmd
    ; "load-file", load_file_cmd
    ; "log", log_cmd
    ; "ls-files", ls_files_cmd
    ; "name-status", name_status_cmd
    ; "num-status", num_status_cmd
    ; "refs", refs_cmd
    ; "rename-current-branch", rename_current_branch_cmd
    ; "save-file", save_file_cmd
    ; "set-user-config", set_user_config_cmd
    ; "show-file-at-rev", show_file_at_rev_cmd
    ; "graph", graph_cmd
    ; "more-tests", more_tests_cmd
    ]
;;
