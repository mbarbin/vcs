(*******************************************************************************)
(*  Vcs - a versatile OCaml library for Git interaction                        *)
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

let eio_command ~summary ?readme command =
  Command.basic_or_error
    ~summary
    ?readme
    (let%map_open.Command () = return ()
     and command = command in
     fun () -> Eio_main.run @@ fun env -> command env)
;;

let add_cmd =
  eio_command
    ~summary:"add a file to the index"
    (let%map_open.Command config = Vcs_param.config
     and path = Vcs_param.anon_path_in_repo in
     fun env ->
       let%bind { vcs; repo_root; context } = Vcs_param.initialize ~env ~config in
       let%bind path = Vcs_param.resolve ~context path in
       let%bind () = Vcs.add vcs ~repo_root ~path in
       return ())
;;

let commit_cmd =
  eio_command
    ~summary:"commit a file"
    (let%map_open.Command config = Vcs_param.config
     and commit_message = Vcs_param.commit_message
     and quiet = Vcs_param.quiet in
     fun env ->
       let%bind commit_message = commit_message in
       let%bind { vcs; repo_root; context = _ } = Vcs_param.initialize ~env ~config in
       let%bind rev = Vcs.commit vcs ~repo_root ~commit_message in
       if not quiet then Eio_writer.print_sexp ~env [%sexp (rev : Vcs.Rev.t)];
       return ())
;;

let init_cmd =
  eio_command
    ~summary:"initialize a new repository"
    (let%map_open.Command config = Vcs_param.config
     and path = Vcs_param.anon_path
     and quiet = Vcs_param.quiet in
     fun env ->
       let%bind { vcs; repo_root = _; context } = Vcs_param.initialize ~env ~config in
       let%bind path = Vcs_param.resolve path ~context in
       let%bind repo_root = Vcs.init vcs ~path in
       if not quiet then Eio_writer.print_sexp ~env [%sexp (repo_root : Vcs.Repo_root.t)];
       return ())
;;

let load_file_cmd =
  eio_command
    ~summary:"print a file from the filesystem (aka cat)"
    (let%map_open.Command config = Vcs_param.config
     and path = Vcs_param.anon_path in
     fun env ->
       let%bind { vcs; repo_root = _; context } = Vcs_param.initialize ~env ~config in
       let%bind path = Vcs_param.resolve path ~context in
       let%bind contents = Vcs.load_file vcs ~path in
       Eio_writer.print_string ~env (contents :> string);
       return ())
;;

let ls_files_cmd =
  eio_command
    ~summary:"list file"
    (let%map_open.Command config = Vcs_param.config
     and below = Vcs_param.below_path_in_repo in
     fun env ->
       let%bind { vcs; repo_root; context } = Vcs_param.initialize ~env ~config in
       let%bind below = Vcs_param.resolve below ~context in
       let below = Option.value below ~default:Vcs.Path_in_repo.root in
       let%bind files = Vcs.ls_files vcs ~repo_root ~below in
       Eio_writer.with_flow (Eio.Stdenv.stdout env) (fun w ->
         List.iter files ~f:(fun file ->
           Eio_writer.write_line w (Vcs.Path_in_repo.to_string file)));
       return ())
;;

let rev_parse_cmd =
  eio_command
    ~summary:"revision of a branch or HEAD"
    (let%map_open.Command config = Vcs_param.config
     and branch_name = Vcs_param.anon_branch_name_opt in
     fun env ->
       let%bind { vcs; repo_root; context = _ } = Vcs_param.initialize ~env ~config in
       let%bind arg =
         match branch_name with
         | None -> return Vcs.Rev_parse.Arg.Head
         | Some branch_name ->
           let%map branch_name = branch_name in
           Vcs.Rev_parse.Arg.Branch { branch_name }
       in
       let%bind rev = Vcs.rev_parse vcs ~repo_root ~arg in
       Eio_writer.print_sexp ~env [%sexp (rev : Vcs.Rev.t)];
       return ())
;;

let rename_current_branch_cmd =
  eio_command
    ~summary:"move/rename a branch to a new name"
    (let%map_open.Command config = Vcs_param.config
     and branch_name = Vcs_param.anon_branch_name in
     fun env ->
       let%bind { vcs; repo_root; context = _ } = Vcs_param.initialize ~env ~config in
       let%bind branch_name = branch_name in
       Vcs.rename_current_branch vcs ~repo_root ~to_:branch_name)
;;

let name_status_cmd =
  eio_command
    ~summary:"show a summary of the diff between 2 revs"
    (let%map_open.Command config = Vcs_param.config
     and src = Vcs_param.anon_rev
     and dst = Vcs_param.anon_rev in
     fun env ->
       let%bind { vcs; repo_root; context = _ } = Vcs_param.initialize ~env ~config in
       let%bind src = src
       and dst = dst in
       let%bind name_status =
         Vcs.name_status vcs ~repo_root ~changed:(Between { src; dst })
       in
       Eio_writer.print_sexp ~env [%sexp (name_status : Vcs.Name_status.t)];
       return ())
;;

let num_status_cmd =
  eio_command
    ~summary:"show a summary of the number of lines of diff between 2 revs"
    (let%map_open.Command config = Vcs_param.config
     and src = Vcs_param.anon_rev
     and dst = Vcs_param.anon_rev in
     fun env ->
       let%bind { vcs; repo_root; context = _ } = Vcs_param.initialize ~env ~config in
       let%bind src = src
       and dst = dst in
       let%bind num_status =
         Vcs.num_status vcs ~repo_root ~changed:(Between { src; dst })
       in
       Eio_writer.print_sexp ~env [%sexp (num_status : Vcs.Num_status.t)];
       return ())
;;

let set_user_config_cmd =
  eio_command
    ~summary:"set the user config"
    (let%map_open.Command config = Vcs_param.config
     and user_name = Vcs_param.user_name
     and user_email = Vcs_param.user_email in
     fun env ->
       let%bind user_name = user_name
       and user_email = user_email in
       let%bind { vcs; repo_root; context = _ } = Vcs_param.initialize ~env ~config in
       let%bind () = Vcs.set_user_name vcs ~repo_root ~user_name in
       let%bind () = Vcs.set_user_email vcs ~repo_root ~user_email in
       return ())
;;

let show_file_at_rev_cmd =
  eio_command
    ~summary:"show the contents of file at a given revision"
    (let%map_open.Command config = Vcs_param.config
     and rev = Vcs_param.rev
     and path = Vcs_param.anon_path_in_repo in
     fun env ->
       let%bind { vcs; repo_root; context } = Vcs_param.initialize ~env ~config in
       let%bind rev = rev in
       let%bind path = Vcs_param.resolve path ~context in
       let%bind result = Vcs.show_file_at_rev vcs ~repo_root ~rev ~path in
       (match result with
        | `Present contents -> Eio_writer.print_string ~env (contents :> string)
        | `Absent ->
          Eio_writer.eprintf
            ~env
            "Path '%s' does not exist in '%s'"
            (Vcs.Path_in_repo.to_string path)
            (Vcs.Rev.to_string rev));
       return ())
;;

let compute_tree_cmd =
  eio_command
    ~summary:"compute_tree in current repo"
    (let%map_open.Command config = Vcs_param.config in
     fun env ->
       let%bind { vcs; repo_root; context = _ } = Vcs_param.initialize ~env ~config in
       let%bind tree = Vcs.tree vcs ~repo_root in
       Eio_writer.print_sexp ~env [%sexp (Vcs.Tree.summary tree : Vcs.Tree.Summary.t)];
       return ())
;;

let main =
  Command.group
    ~summary:"call a command from the vcs interface"
    ~readme:(fun () ->
      {|
This is an executable to test the Version Control System (vcs) library.

We expect a 1:1 mapping between the function exposed in the [Vcs.S] and the
sub commands exposed here.
|})
    [ "add-cmd", add_cmd
    ; "commit", commit_cmd
    ; "compute-tree", compute_tree_cmd
    ; "init-cmd", init_cmd
    ; "load-file", load_file_cmd
    ; "ls-files", ls_files_cmd
    ; "name-status", name_status_cmd
    ; "num-status", num_status_cmd
    ; "rename-current-branch", rename_current_branch_cmd
    ; "rev-parse", rev_parse_cmd
    ; "set-user-config", set_user_config_cmd
    ; "show-file-at-rev", show_file_at_rev_cmd
    ]
;;
