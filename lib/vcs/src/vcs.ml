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

module Author = Author
module Branch_name = Branch_name
module Commit_message = Commit_message
module File_contents = File_contents
module Git = Git
module Log = Log
module Mock_rev_gen = Mock_rev_gen
module Mock_revs = Mock_revs
module Name_status = Name_status
module Num_status = Num_status
module Num_lines_in_diff = Num_lines_in_diff
module Path_in_repo = Path_in_repo
module Platform = Platform
module Ref_kind = Ref_kind
module Refs = Refs
module Remote_branch_name = Remote_branch_name
module Remote_name = Remote_name
module Repo_name = Repo_name
module Repo_root = Repo_root
module Rev = Rev
module Rev_parse = Rev_parse
module Tag_name = Tag_name
module Trait = Trait
module Tree = Tree
module Url = Url
module User_email = User_email
module User_handle = User_handle
module User_name = User_name

type 'a t = 'a Provider.t

let create provider = provider

let load_file (Provider.T { t; interface }) ~path =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.File_system) in
  M.load_file t ~path
;;

let save_file ?perms (Provider.T { t; interface }) ~path ~file_contents =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.File_system) in
  M.save_file ?perms t ~path ~file_contents
;;

let add (Provider.T { t; interface }) ~repo_root ~path =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Add) in
  M.add t ~repo_root ~path
;;

let init (Provider.T { t; interface }) ~path =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Init) in
  M.init t ~path
;;

let rev_parse (Provider.T { t; interface }) ~repo_root ~arg =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Rev_parse) in
  M.rev_parse t ~repo_root ~arg
;;

let commit (Provider.T { t; interface } as vcs) ~repo_root ~commit_message =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Commit) in
  let%bind () = M.commit t ~repo_root ~commit_message in
  rev_parse vcs ~repo_root ~arg:Head
;;

let ls_files (Provider.T { t; interface }) ~repo_root ~below =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Ls_files) in
  M.ls_files t ~repo_root ~below
;;

let rename_current_branch (Provider.T { t; interface }) ~repo_root ~to_ =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Branch) in
  M.rename_current_branch t ~repo_root ~to_
;;

let name_status (Provider.T { t; interface }) ~repo_root ~changed =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Name_status) in
  M.diff t ~repo_root ~changed
;;

let num_status (Provider.T { t; interface }) ~repo_root ~changed =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Num_status) in
  M.diff t ~repo_root ~changed
;;

let log (Provider.T { t; interface }) ~repo_root =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Log) in
  M.all t ~repo_root
;;

let refs (Provider.T { t; interface }) ~repo_root =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Refs) in
  M.show_ref t ~repo_root
;;

let tree vcs ~repo_root =
  let tree = Tree.create () in
  let%bind log = log vcs ~repo_root in
  let%bind refs = refs vcs ~repo_root in
  Tree.add_nodes tree ~log;
  List.iter refs ~f:(fun { rev; ref_kind } -> Tree.set_ref tree ~rev ~ref_kind);
  return tree
;;

let set_user_name (Provider.T { t; interface }) ~repo_root ~user_name =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Config) in
  M.set_user_name t ~repo_root ~user_name
;;

let set_user_email (Provider.T { t; interface }) ~repo_root ~user_email =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Config) in
  M.set_user_email t ~repo_root ~user_email
;;

let show_file_at_rev (Provider.T { t; interface }) ~repo_root ~rev ~path =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Show) in
  M.show_file_at_rev t ~repo_root ~rev ~path
;;

let git
  ?env
  ?(run_in_subdir = Path_in_repo.root)
  (Provider.T { t; interface })
  ~repo_root
  ~args
  ~f
  =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Git) in
  M.git ?env t ~cwd:(Repo_root.append repo_root run_in_subdir) ~args ~f
;;

module For_test = struct
  let init vcs ~path =
    let%bind repo_root = init vcs ~path in
    let%bind () = set_user_name vcs ~repo_root ~user_name:(User_name.v "Test User") in
    let%bind () =
      set_user_email vcs ~repo_root ~user_email:(User_email.v "test@example.com")
    in
    return repo_root
  ;;
end
