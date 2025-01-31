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

open! Import

type 'a t = 'a Provider.packed

let create provider = provider

let of_result ~step = function
  | Ok r -> r
  | Error err -> raise (Exn0.E (Err.add_context err ~step:(Lazy.force step)))
;;

let load_file (Provider.T { t; provider }) ~path =
  let module M = (val Provider.lookup provider ~trait:Trait.File_system.t) in
  M.load_file t ~path
  |> of_result ~step:(lazy [%sexp "Vcs.load_file", { path : Absolute_path.t }])
;;

let save_file ?perms (Provider.T { t; provider }) ~path ~file_contents =
  let module M = (val Provider.lookup provider ~trait:Trait.File_system.t) in
  M.save_file ?perms t ~path ~file_contents
  |> of_result
       ~step:
         (lazy [%sexp "Vcs.save_file", { perms : int option; path : Absolute_path.t }])
;;

let read_dir (Provider.T { t; provider }) ~dir =
  let module M = (val Provider.lookup provider ~trait:Trait.File_system.t) in
  M.read_dir t ~dir
  |> of_result ~step:(lazy [%sexp "Vcs.read_dir", { dir : Absolute_path.t }])
;;

let add (Provider.T { t; provider }) ~repo_root ~path =
  let module M = (val Provider.lookup provider ~trait:Trait.Add.t) in
  M.add t ~repo_root ~path
  |> of_result
       ~step:(lazy [%sexp "Vcs.add", { repo_root : Repo_root.t; path : Path_in_repo.t }])
;;

let init (Provider.T { t; provider }) ~path =
  let module M = (val Provider.lookup provider ~trait:Trait.Init.t) in
  M.init t ~path |> of_result ~step:(lazy [%sexp "Vcs.init", { path : Absolute_path.t }])
;;

let find_enclosing_repo_root t ~from ~store =
  let rec visit dir =
    let entries = read_dir t ~dir in
    match
      List.find_map entries ~f:(fun entry ->
        List.find_map store ~f:(fun (seg, store) ->
          Option.some_if (Fsegment.equal seg entry) store))
    with
    | Some store ->
      let dir =
        Fpath.rem_empty_seg (dir :> Fpath.t)
        |> Absolute_path.of_fpath
        |> Option.value ~default:dir
      in
      Some (store, Repo_root.of_absolute_path dir)
    | None ->
      (match Absolute_path.parent dir with
       | None -> None
       | Some parent_dir -> visit parent_dir)
  in
  visit from
;;

let find_enclosing_git_repo_root t ~from =
  match find_enclosing_repo_root t ~from ~store:[ Fsegment.dot_git, `Git ] with
  | None -> None
  | Some (`Git, repo_root) -> Some repo_root
;;

let current_branch (Provider.T { t; provider }) ~repo_root =
  let module M = (val Provider.lookup provider ~trait:Trait.Rev_parse.t) in
  M.current_branch t ~repo_root
  |> of_result ~step:(lazy [%sexp "Vcs.current_branch", { repo_root : Repo_root.t }])
;;

let current_revision (Provider.T { t; provider }) ~repo_root =
  let module M = (val Provider.lookup provider ~trait:Trait.Rev_parse.t) in
  M.current_revision t ~repo_root
  |> of_result ~step:(lazy [%sexp "Vcs.current_revision", { repo_root : Repo_root.t }])
;;

let commit (Provider.T { t; provider }) ~repo_root ~commit_message =
  let module R = (val Provider.lookup provider ~trait:Trait.Rev_parse.t) in
  let module C = (val Provider.lookup provider ~trait:Trait.Commit.t) in
  (let open Result.Monad_syntax in
   let* () = C.commit t ~repo_root ~commit_message in
   R.current_revision t ~repo_root)
  |> of_result ~step:(lazy [%sexp "Vcs.commit", { repo_root : Repo_root.t }])
;;

let ls_files (Provider.T { t; provider }) ~repo_root ~below =
  let module M = (val Provider.lookup provider ~trait:Trait.Ls_files.t) in
  M.ls_files t ~repo_root ~below
  |> of_result
       ~step:
         (lazy
           [%sexp "Vcs.ls_files", { repo_root : Repo_root.t; below : Path_in_repo.t }])
;;

let rename_current_branch (Provider.T { t; provider }) ~repo_root ~to_ =
  let module M = (val Provider.lookup provider ~trait:Trait.Branch.t) in
  M.rename_current_branch t ~repo_root ~to_
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.rename_current_branch", { repo_root : Repo_root.t; to_ : Branch_name.t }])
;;

let name_status (Provider.T { t; provider }) ~repo_root ~changed =
  let module M = (val Provider.lookup provider ~trait:Trait.Name_status.t) in
  M.diff t ~repo_root ~changed
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.name_status"
           , { repo_root : Repo_root.t; changed : Name_status.Changed.t }])
;;

let num_status (Provider.T { t; provider }) ~repo_root ~changed =
  let module M = (val Provider.lookup provider ~trait:Trait.Num_status.t) in
  M.diff t ~repo_root ~changed
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.num_status", { repo_root : Repo_root.t; changed : Num_status.Changed.t }])
;;

let log (Provider.T { t; provider }) ~repo_root =
  let module M = (val Provider.lookup provider ~trait:Trait.Log.t) in
  M.all t ~repo_root
  |> of_result ~step:(lazy [%sexp "Vcs.log", { repo_root : Repo_root.t }])
;;

let refs (Provider.T { t; provider }) ~repo_root =
  let module M = (val Provider.lookup provider ~trait:Trait.Refs.t) in
  M.show_ref t ~repo_root
  |> of_result ~step:(lazy [%sexp "Vcs.refs", { repo_root : Repo_root.t }])
;;

let graph (Provider.T { t; provider }) ~repo_root =
  let module L = (val Provider.lookup provider ~trait:Trait.Log.t) in
  let module R = (val Provider.lookup provider ~trait:Trait.Refs.t) in
  let graph = Graph.create () in
  (let open Result.Monad_syntax in
   let* log = L.all t ~repo_root in
   let* refs = R.show_ref t ~repo_root in
   Graph.add_nodes graph ~log;
   Graph.set_refs graph ~refs;
   Result.return graph)
  |> of_result ~step:(lazy [%sexp "Vcs.graph", { repo_root : Repo_root.t }])
;;

let set_user_name (Provider.T { t; provider }) ~repo_root ~user_name =
  let module M = (val Provider.lookup provider ~trait:Trait.Config.t) in
  M.set_user_name t ~repo_root ~user_name
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.set_user_name", { repo_root : Repo_root.t; user_name : User_name.t }])
;;

let set_user_email (Provider.T { t; provider }) ~repo_root ~user_email =
  let module M = (val Provider.lookup provider ~trait:Trait.Config.t) in
  M.set_user_email t ~repo_root ~user_email
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.set_user_email", { repo_root : Repo_root.t; user_email : User_email.t }])
;;

let show_file_at_rev (Provider.T { t; provider }) ~repo_root ~rev ~path =
  let module M = (val Provider.lookup provider ~trait:Trait.Show.t) in
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

let non_raising_git
      ?env
      ?(run_in_subdir = Path_in_repo.root)
      (Provider.T { t; provider })
      ~repo_root
      ~args
      ~f
  =
  let module M = (val Provider.lookup provider ~trait:Trait.Git.t) in
  let cwd = Repo_root.append repo_root run_in_subdir in
  M.git ?env t ~cwd ~args ~f
;;

let git ?env ?run_in_subdir vcs ~repo_root ~args ~f =
  non_raising_git ?env ?run_in_subdir vcs ~repo_root ~args ~f:(fun output ->
    Vcs_exn.Private.try_with (fun () -> f output))
  |> of_result ~step:(lazy (make_git_err_step ?env ?run_in_subdir ~repo_root ~args ()))
;;

module Private = struct
  let git = non_raising_git
  let make_git_err_step = make_git_err_step
end
