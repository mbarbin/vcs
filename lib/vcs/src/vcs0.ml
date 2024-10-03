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

type 'a t = 'a Provider.t

let create provider = provider

let of_result ~step = function
  | Ok r -> r
  | Error error -> raise (Exn0.E (Err.init error ~step:(force step)))
;;

let load_file (Provider.T { t; handler }) ~path =
  let module M = (val Provider.Handler.lookup handler ~trait:Trait.File_system) in
  M.load_file t ~path
  |> of_result ~step:(lazy [%sexp "Vcs.load_file", { path : Absolute_path.t }])
;;

let save_file ?perms (Provider.T { t; handler }) ~path ~file_contents =
  let module M = (val Provider.Handler.lookup handler ~trait:Trait.File_system) in
  M.save_file ?perms t ~path ~file_contents
  |> of_result
       ~step:
         (lazy [%sexp "Vcs.save_file", { perms : int option; path : Absolute_path.t }])
;;

let read_dir (Provider.T { t; handler }) ~dir =
  let module M = (val Provider.Handler.lookup handler ~trait:Trait.File_system) in
  M.read_dir t ~dir
  |> of_result ~step:(lazy [%sexp "Vcs.read_dir", { dir : Absolute_path.t }])
;;

let add (Provider.T { t; handler }) ~repo_root ~path =
  let module M = (val Provider.Handler.lookup handler ~trait:Trait.Add) in
  M.add t ~repo_root ~path
  |> of_result
       ~step:(lazy [%sexp "Vcs.add", { repo_root : Repo_root.t; path : Path_in_repo.t }])
;;

let init (Provider.T { t; handler }) ~path =
  let module M = (val Provider.Handler.lookup handler ~trait:Trait.Init) in
  M.init t ~path |> of_result ~step:(lazy [%sexp "Vcs.init", { path : Absolute_path.t }])
;;

let current_branch (Provider.T { t; handler }) ~repo_root =
  let module M = (val Provider.Handler.lookup handler ~trait:Trait.Rev_parse) in
  M.current_branch t ~repo_root
  |> of_result ~step:(lazy [%sexp "Vcs.current_branch", { repo_root : Repo_root.t }])
;;

let current_revision (Provider.T { t; handler }) ~repo_root =
  let module M = (val Provider.Handler.lookup handler ~trait:Trait.Rev_parse) in
  M.current_revision t ~repo_root
  |> of_result ~step:(lazy [%sexp "Vcs.current_revision", { repo_root : Repo_root.t }])
;;

let commit (Provider.T { t; handler }) ~repo_root ~commit_message =
  let module R = (val Provider.Handler.lookup handler ~trait:Trait.Rev_parse) in
  let module C = (val Provider.Handler.lookup handler ~trait:Trait.Commit) in
  (let%bind.Or_error () = C.commit t ~repo_root ~commit_message in
   R.current_revision t ~repo_root)
  |> of_result ~step:(lazy [%sexp "Vcs.commit", { repo_root : Repo_root.t }])
;;

let ls_files (Provider.T { t; handler }) ~repo_root ~below =
  let module M = (val Provider.Handler.lookup handler ~trait:Trait.Ls_files) in
  M.ls_files t ~repo_root ~below
  |> of_result
       ~step:
         (lazy
           [%sexp "Vcs.ls_files", { repo_root : Repo_root.t; below : Path_in_repo.t }])
;;

let rename_current_branch (Provider.T { t; handler }) ~repo_root ~to_ =
  let module M = (val Provider.Handler.lookup handler ~trait:Trait.Branch) in
  M.rename_current_branch t ~repo_root ~to_
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.rename_current_branch", { repo_root : Repo_root.t; to_ : Branch_name.t }])
;;

let name_status (Provider.T { t; handler }) ~repo_root ~changed =
  let module M = (val Provider.Handler.lookup handler ~trait:Trait.Name_status) in
  M.diff t ~repo_root ~changed
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.name_status"
             , { repo_root : Repo_root.t; changed : Name_status.Changed.t }])
;;

let num_status (Provider.T { t; handler }) ~repo_root ~changed =
  let module M = (val Provider.Handler.lookup handler ~trait:Trait.Num_status) in
  M.diff t ~repo_root ~changed
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.num_status", { repo_root : Repo_root.t; changed : Num_status.Changed.t }])
;;

let log (Provider.T { t; handler }) ~repo_root =
  let module M = (val Provider.Handler.lookup handler ~trait:Trait.Log) in
  M.all t ~repo_root
  |> of_result ~step:(lazy [%sexp "Vcs.log", { repo_root : Repo_root.t }])
;;

let refs (Provider.T { t; handler }) ~repo_root =
  let module M = (val Provider.Handler.lookup handler ~trait:Trait.Refs) in
  M.show_ref t ~repo_root
  |> of_result ~step:(lazy [%sexp "Vcs.refs", { repo_root : Repo_root.t }])
;;

let graph (Provider.T { t; handler }) ~repo_root =
  let module L = (val Provider.Handler.lookup handler ~trait:Trait.Log) in
  let module R = (val Provider.Handler.lookup handler ~trait:Trait.Refs) in
  let graph = Graph.create () in
  (let open Or_error.Let_syntax in
   let%bind log = L.all t ~repo_root in
   let%bind refs = R.show_ref t ~repo_root in
   Graph.add_nodes graph ~log;
   Graph.set_refs graph ~refs;
   return graph)
  |> of_result ~step:(lazy [%sexp "Vcs.graph", { repo_root : Repo_root.t }])
;;

let set_user_name (Provider.T { t; handler }) ~repo_root ~user_name =
  let module M = (val Provider.Handler.lookup handler ~trait:Trait.Config) in
  M.set_user_name t ~repo_root ~user_name
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.set_user_name", { repo_root : Repo_root.t; user_name : User_name.t }])
;;

let set_user_email (Provider.T { t; handler }) ~repo_root ~user_email =
  let module M = (val Provider.Handler.lookup handler ~trait:Trait.Config) in
  M.set_user_email t ~repo_root ~user_email
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.set_user_email", { repo_root : Repo_root.t; user_email : User_email.t }])
;;

let show_file_at_rev (Provider.T { t; handler }) ~repo_root ~rev ~path =
  let module M = (val Provider.Handler.lookup handler ~trait:Trait.Show) in
  M.show_file_at_rev t ~repo_root ~rev ~path
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.show_file_at_rev"
             , { repo_root : Repo_root.t; rev : Rev.t; path : Path_in_repo.t }])
;;

let make_git_err_step ?env ?run_in_subdir ~repo_root ~args () =
  [%sexp
    "Vcs.git"
    , { repo_root : Repo_root.t
      ; run_in_subdir : (Path_in_repo.t option[@sexp.option])
      ; env : (string array option[@sexp.option])
      ; args : string list
      }]
;;

let git ?env ?run_in_subdir (Provider.T { t; handler }) ~repo_root ~args ~f =
  let module M = (val Provider.Handler.lookup handler ~trait:Trait.Git) in
  let cwd =
    Repo_root.append repo_root (Option.value run_in_subdir ~default:Path_in_repo.root)
  in
  M.git ?env t ~cwd ~args ~f:(fun output -> Or_error.try_with (fun () -> f output))
  |> of_result ~step:(lazy (make_git_err_step ?env ?run_in_subdir ~repo_root ~args ()))
;;

module Private = struct
  let git
    ?env
    ?(run_in_subdir = Path_in_repo.root)
    (Provider.T { t; handler })
    ~repo_root
    ~args
    ~f
    =
    let module M = (val Provider.Handler.lookup handler ~trait:Trait.Git) in
    let cwd = Repo_root.append repo_root run_in_subdir in
    M.git ?env t ~cwd ~args ~f
  ;;

  let make_git_err_step = make_git_err_step
end
