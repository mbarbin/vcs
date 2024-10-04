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

let print_sexp sexp = Stdlib.print_endline (Sexp.to_string_hum sexp)

module Initialized = struct
  type t =
    { vcs : Vcs_git_eio.t'
    ; repo_root : Vcs.Repo_root.t
    ; cwd : Absolute_path.t
    }
end

let find_enclosing_repo_root vcs ~from =
  match Vcs.find_enclosing_repo_root vcs ~from ~store:[ Fpart.dot_git ] with
  | Some (`Store _, repo_root) -> repo_root
  | None ->
    Vcs.raise_s
      "Failed to locate enclosing repo root from directory"
      [%sexp { from : Absolute_path.t }]
;;

let initialize ~env =
  let vcs = Vcs_git_eio.create ~env in
  let cwd = Unix.getcwd () |> Absolute_path.v in
  let repo_root = find_enclosing_repo_root vcs ~from:cwd in
  { Initialized.vcs; repo_root; cwd }
;;

let relativize ~repo_root ~cwd ~path =
  let path = Absolute_path.relativize ~root:cwd path in
  match
    Absolute_path.chop_prefix path ~prefix:(repo_root |> Vcs.Repo_root.to_absolute_path)
  with
  | Some relative_path -> Vcs.Path_in_repo.of_relative_path relative_path
  | None -> Vcs.raise_s "Path is not in repo" [%sexp { path : Absolute_path.t }]
;;

let add_cmd =
  Command.make
    ~summary:"add a file to the index"
    (let%map_open.Command path =
       Arg.pos
         ~pos:0
         (Param.validated_string (module Fpath))
         ~docv:"file"
         ~doc:"file to add"
     in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root; cwd } = initialize ~env in
     let path = relativize ~repo_root ~cwd ~path in
     Vcs.add vcs ~repo_root ~path;
     ())
;;

let commit_cmd =
  Command.make
    ~summary:"commit a file"
    (let%map_open.Command commit_message =
       Arg.named
         [ "message"; "m" ]
         (Param.validated_string (module Vcs.Commit_message))
         ~docv:"MSG"
         ~doc:"commit message"
     and quiet = Arg.flag [ "quiet"; "q" ] ~doc:"suppress output on success" in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root; cwd = _ } = initialize ~env in
     let rev = Vcs.commit vcs ~repo_root ~commit_message in
     if not quiet then print_sexp [%sexp (rev : Vcs.Rev.t)];
     ())
;;

let current_branch_cmd =
  Command.make
    ~summary:"current branch"
    (let%map_open.Command () = Arg.return () in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root; cwd = _ } = initialize ~env in
     let branch = Vcs.current_branch vcs ~repo_root in
     print_sexp [%sexp (branch : Vcs.Branch_name.t)];
     ())
;;

let current_revision_cmd =
  Command.make
    ~summary:"revision of HEAD"
    (let%map_open.Command () = Arg.return () in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root; cwd = _ } = initialize ~env in
     let rev = Vcs.current_revision vcs ~repo_root in
     print_sexp [%sexp (rev : Vcs.Rev.t)];
     ())
;;

let find_enclosing_repo_root_cmd =
  Command.make
    ~summary:"find enclosing repo root"
    (let%map_open.Command from =
       Arg.named_opt
         [ "from" ]
         (Param.validated_string (module Fpath))
         ~docv:"path/to/dir"
         ~doc:"walk up from the supplied directory (default is cwd)"
     and store =
       Arg.named_opt
         [ "store" ]
         (Param.comma_separated (Param.validated_string (module Fpart)))
         ~doc:"stop the search if one of these entries is found (e.g. '.hg')"
       >>| Option.value ~default:[ Fpart.dot_git ]
     in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root = _; cwd } = initialize ~env in
     let from =
       match from with
       | None -> cwd
       | Some from -> Absolute_path.relativize ~root:cwd from
     in
     match Vcs.find_enclosing_repo_root vcs ~from ~store with
     | None -> ()
     | Some (`Store store, repo_root) ->
       Stdlib.Printf.printf
         "%s: %s\n"
         (Fpart.to_string store)
         (Vcs.Repo_root.to_string repo_root))
;;

let git_cmd =
  Command.make
    ~summary:"run the git cli"
    (let%map_open.Command args =
       Arg.pos_all Param.string ~docv:"ARG" ~doc:"pass the remaining args to git"
     in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root; cwd = _ } = initialize ~env in
     let { Vcs.Git.Output.exit_code; stdout; stderr } =
       Vcs.git vcs ~repo_root ~args ~f:Fn.id
     in
     Stdlib.print_string stdout;
     Stdlib.prerr_string stderr;
     if exit_code <> 0 then Stdlib.exit exit_code)
;;

let init_cmd =
  Command.make
    ~summary:"initialize a new repository"
    (let%map_open.Command path =
       Arg.pos
         ~pos:0
         (Param.validated_string (module Fpath))
         ~docv:"path/to/root"
         ~doc:"where to initialize the repository"
     and quiet =
       Arg.flag [ "quiet"; "q" ] ~doc:"do not print the initialized repo root"
     in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root = _; cwd } = initialize ~env in
     let path = Absolute_path.relativize ~root:cwd path in
     let repo_root = Vcs.init vcs ~path in
     if not quiet then print_sexp [%sexp (repo_root : Vcs.Repo_root.t)] [@coverage off];
     ())
;;

let load_file_cmd =
  Command.make
    ~summary:"print a file from the filesystem (aka cat)"
    (let%map_open.Command path =
       Arg.pos
         ~pos:0
         (Param.validated_string (module Fpath))
         ~docv:"path/to/file"
         ~doc:"file to load"
     in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root = _; cwd } = initialize ~env in
     let path = Absolute_path.relativize ~root:cwd path in
     let contents = Vcs.load_file vcs ~path in
     Stdlib.print_string (contents :> string);
     ())
;;

let ls_files_cmd =
  Command.make
    ~summary:"list file"
    (let%map_open.Command below =
       Arg.named_opt
         [ "below" ]
         (Param.validated_string (module Fpath))
         ~docv:"PATH"
         ~doc:"restrict the selection to path/to/subdir"
     in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root; cwd } = initialize ~env in
     let below =
       match below with
       | None -> Vcs.Path_in_repo.root
       | Some path -> relativize ~repo_root ~cwd ~path
     in
     let files = Vcs.ls_files vcs ~repo_root ~below in
     List.iter files ~f:(fun file ->
       Stdlib.print_endline (Vcs.Path_in_repo.to_string file));
     ())
;;

let log_cmd =
  Command.make
    ~summary:"show the log of current repo"
    (let%map_open.Command () = Arg.return () in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root; cwd = _ } = initialize ~env in
     let log = Vcs.log vcs ~repo_root in
     print_sexp [%sexp (log : Vcs.Log.t)];
     ())
;;

let name_status_cmd =
  Command.make
    ~summary:"show a summary of the diff between 2 revs"
    (let%map_open.Command src =
       Arg.pos
         ~pos:0
         (Param.validated_string (module Vcs.Rev))
         ~docv:"BASE"
         ~doc:"base revision"
     and dst =
       Arg.pos
         ~pos:1
         (Param.validated_string (module Vcs.Rev))
         ~docv:"TIP"
         ~doc:"tip revision"
     in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root; cwd = _ } = initialize ~env in
     let name_status = Vcs.name_status vcs ~repo_root ~changed:(Between { src; dst }) in
     print_sexp [%sexp (name_status : Vcs.Name_status.t)];
     ())
;;

let num_status_cmd =
  Command.make
    ~summary:"show a summary of the number of lines of diff between 2 revs"
    (let%map_open.Command src =
       Arg.pos
         ~pos:0
         (Param.validated_string (module Vcs.Rev))
         ~docv:"BASE"
         ~doc:"base revision"
     and dst =
       Arg.pos
         ~pos:1
         (Param.validated_string (module Vcs.Rev))
         ~docv:"TIP"
         ~doc:"tip revision"
     in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root; cwd = _ } = initialize ~env in
     let num_status = Vcs.num_status vcs ~repo_root ~changed:(Between { src; dst }) in
     print_sexp [%sexp (num_status : Vcs.Num_status.t)];
     ())
;;

let read_dir_cmd =
  Command.make
    ~summary:"print the list of files in a directory"
    (let%map_open.Command dir =
       Arg.pos
         ~pos:0
         (Param.validated_string (module Fpath))
         ~docv:"path/to/dir"
         ~doc:"dir to read"
     in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root = _; cwd } = initialize ~env in
     let dir = Absolute_path.relativize ~root:cwd dir in
     let entries = Vcs.read_dir vcs ~dir in
     print_sexp [%sexp (entries : Fpart.t list)];
     ())
;;

let rename_current_branch_cmd =
  Command.make
    ~summary:"move/rename a branch to a new name"
    (let%map_open.Command branch_name =
       Arg.pos
         ~pos:0
         (Param.validated_string (module Vcs.Branch_name))
         ~docv:"branch"
         ~doc:"new name to rename to"
     in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root; cwd = _ } = initialize ~env in
     Vcs.rename_current_branch vcs ~repo_root ~to_:branch_name;
     ())
;;

let refs_cmd =
  Command.make
    ~summary:"show the refs of current repo"
    (let%map_open.Command () = Arg.return () in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root; cwd = _ } = initialize ~env in
     let refs = Vcs.refs vcs ~repo_root in
     print_sexp [%sexp (refs : Vcs.Refs.t)];
     ())
;;

let save_file_cmd =
  Command.make
    ~summary:"save stdin to a file from the filesystem (aka tee)"
    (let%map_open.Command path =
       Arg.pos
         ~pos:0
         (Param.validated_string (module Fpath))
         ~docv:"FILE"
         ~doc:"path to file where to save the contents to"
     in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root = _; cwd } = initialize ~env in
     let path = Absolute_path.relativize ~root:cwd path in
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
    (let%map_open.Command user_name =
       Arg.named
         [ "user.name" ]
         (Param.validated_string (module Vcs.User_name))
         ~docv:"USER"
         ~doc:"user name"
     and user_email =
       Arg.named
         [ "user.email" ]
         (Param.validated_string (module Vcs.User_email))
         ~docv:"EMAIL"
         ~doc:"user email"
     in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root; cwd = _ } = initialize ~env in
     Vcs.set_user_name vcs ~repo_root ~user_name;
     Vcs.set_user_email vcs ~repo_root ~user_email;
     ())
;;

let show_file_at_rev_cmd =
  Command.make
    ~summary:"show the contents of file at a given revision"
    (let%map_open.Command rev =
       Arg.named
         [ "rev"; "r" ]
         (Param.validated_string (module Vcs.Rev))
         ~docv:"REV"
         ~doc:"revision to show"
     and path =
       Arg.pos
         ~pos:0
         (Param.validated_string (module Fpath))
         ~docv:"FILE"
         ~doc:"path to file"
     in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root; cwd } = initialize ~env in
     let path = relativize ~repo_root ~cwd ~path in
     let result = Vcs.show_file_at_rev vcs ~repo_root ~rev ~path in
     (match result with
      | `Present contents -> Stdlib.print_string (contents :> string)
      | `Absent ->
        Stdlib.Printf.eprintf
          "Path '%s' does not exist in '%s'"
          (Vcs.Path_in_repo.to_string path)
          (Vcs.Rev.to_string rev));
     ())
;;

let graph_cmd =
  Command.make
    ~summary:"compute graph of current repo"
    (let%map_open.Command () = Arg.return () in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root; cwd = _ } = initialize ~env in
     let graph = Vcs.graph vcs ~repo_root in
     print_sexp [%sexp (Vcs.Graph.summary graph : Vcs.Graph.Summary.t)];
     ())
;;

(* The following section expands the cli to help with test coverage. *)

let branch_revision_cmd =
  Command.make
    ~summary:"revision of a branch"
    (let%map_open.Command branch_name =
       Arg.pos_opt
         ~pos:0
         (Param.validated_string (module Vcs.Branch_name))
         ~docv:"BRANCH"
         ~doc:"which branch"
     in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root; cwd = _ } = initialize ~env in
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
     print_sexp [%sexp (rev : Vcs.Rev.t)];
     ())
;;

let greatest_common_ancestors_cmd =
  Command.make
    ~summary:"print greatest common ancestors of revisions"
    (let%map_open.Command revs =
       Arg.pos_all
         (Param.validated_string (module Vcs.Rev))
         ~docv:"REV"
         ~doc:"all revisions that must descend from the gcas"
     in
     Eio_main.run
     @@ fun env ->
     let { Initialized.vcs; repo_root; cwd = _ } = initialize ~env in
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
     print_sexp [%sexp (gca : Vcs.Rev.t list)];
     ())
;;

let main =
  Command.group
    ~summary:"call a command from the vcs interface"
    ~readme:(fun () ->
      {|
This is an executable to test the Version Control System (vcs) library.

We expect a 1:1 mapping between the function exposed in the [Vcs.S] and the
sub commands exposed here, plus additional ones.
|})
    [ "add", add_cmd
    ; "branch-revision", branch_revision_cmd
    ; "commit", commit_cmd
    ; "current-branch", current_branch_cmd
    ; "current-revision", current_revision_cmd
    ; "find-enclosing-repo-root", find_enclosing_repo_root_cmd
    ; "gca", greatest_common_ancestors_cmd
    ; "git", git_cmd
    ; "graph", graph_cmd
    ; "init", init_cmd
    ; "load-file", load_file_cmd
    ; "log", log_cmd
    ; "ls-files", ls_files_cmd
    ; "name-status", name_status_cmd
    ; "num-status", num_status_cmd
    ; "read-dir", read_dir_cmd
    ; "refs", refs_cmd
    ; "rename-current-branch", rename_current_branch_cmd
    ; "save-file", save_file_cmd
    ; "set-user-config", set_user_config_cmd
    ; "show-file-at-rev", show_file_at_rev_cmd
    ]
;;
