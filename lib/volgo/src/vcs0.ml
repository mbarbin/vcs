(*******************************************************************************)
(*  Volgo - a Versatile OCaml Library for Git Operations                       *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
(*                                                                             *)
(*  This file is part of Volgo.                                                *)
(*                                                                             *)
(*  Volgo is free software; you can redistribute it and/or modify it under     *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Volgo is distributed in the hope that it will be useful, but WITHOUT ANY   *)
(*  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*  the file `NOTICE.md` at the root of this repository for more details.      *)
(*                                                                             *)
(*  You should have received a copy of the GNU Lesser General Public License   *)
(*  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*******************************************************************************)

open! Import

type +'a t = 'a constraint 'a = < .. >

let create traits = traits

let of_result ~step = function
  | Ok r -> r
  | Error err -> raise (Err.E (Err.add_context err [ Err.sexp (Lazy.force step) ]))
;;

let load_file (t : < Trait.file_system ; .. > t) ~path =
  t#load_file ~path
  |> of_result ~step:(lazy [%sexp "Vcs.load_file", { path : Absolute_path.t }])
;;

let save_file ?perms (t : < Trait.file_system ; .. > t) ~path ~file_contents =
  t#save_file ?perms () ~path ~file_contents
  |> of_result
       ~step:
         (lazy [%sexp "Vcs.save_file", { perms : int option; path : Absolute_path.t }])
;;

let read_dir (t : < Trait.file_system ; .. > t) ~dir =
  t#read_dir ~dir
  |> of_result ~step:(lazy [%sexp "Vcs.read_dir", { dir : Absolute_path.t }])
;;

let add (t : < Trait.add ; .. > t) ~repo_root ~path =
  t#add ~repo_root ~path
  |> of_result
       ~step:(lazy [%sexp "Vcs.add", { repo_root : Repo_root.t; path : Path_in_repo.t }])
;;

let init (t : < Trait.init ; .. > t) ~path =
  t#init ~path |> of_result ~step:(lazy [%sexp "Vcs.init", { path : Absolute_path.t }])
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

let current_branch (t : < Trait.rev_parse ; .. > t) ~repo_root =
  t#current_branch ~repo_root
  |> of_result ~step:(lazy [%sexp "Vcs.current_branch", { repo_root : Repo_root.t }])
;;

let current_revision (t : < Trait.rev_parse ; .. > t) ~repo_root =
  t#current_revision ~repo_root
  |> of_result ~step:(lazy [%sexp "Vcs.current_revision", { repo_root : Repo_root.t }])
;;

let commit (t : < Trait.rev_parse ; Trait.commit ; .. > t) ~repo_root ~commit_message =
  (let open Result.Monad_syntax in
   let* () = t#commit ~repo_root ~commit_message in
   t#current_revision ~repo_root)
  |> of_result ~step:(lazy [%sexp "Vcs.commit", { repo_root : Repo_root.t }])
;;

let ls_files (t : < Trait.ls_files ; .. > t) ~repo_root ~below =
  t#ls_files ~repo_root ~below
  |> of_result
       ~step:
         (lazy
           [%sexp "Vcs.ls_files", { repo_root : Repo_root.t; below : Path_in_repo.t }])
;;

let rename_current_branch (t : < Trait.branch ; .. > t) ~repo_root ~to_ =
  t#rename_current_branch ~repo_root ~to_
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.rename_current_branch", { repo_root : Repo_root.t; to_ : Branch_name.t }])
;;

let name_status (t : < Trait.name_status ; .. > t) ~repo_root ~changed =
  t#name_status ~repo_root ~changed
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.name_status"
           , { repo_root : Repo_root.t; changed : Name_status.Changed.t }])
;;

let num_status (t : < Trait.num_status ; .. > t) ~repo_root ~changed =
  t#num_status ~repo_root ~changed
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.num_status", { repo_root : Repo_root.t; changed : Num_status.Changed.t }])
;;

let log (t : < Trait.log ; .. > t) ~repo_root =
  t#all ~repo_root
  |> of_result ~step:(lazy [%sexp "Vcs.log", { repo_root : Repo_root.t }])
;;

let refs (t : < Trait.refs ; .. > t) ~repo_root =
  t#show_ref ~repo_root
  |> of_result ~step:(lazy [%sexp "Vcs.refs", { repo_root : Repo_root.t }])
;;

let graph (t : < Trait.log ; Trait.refs ; .. > t) ~repo_root =
  let graph = Graph.create () in
  (let open Result.Monad_syntax in
   let* log = t#all ~repo_root in
   let* refs = t#show_ref ~repo_root in
   Graph.add_nodes graph ~log;
   Graph.set_refs graph ~refs;
   Result.return graph)
  |> of_result ~step:(lazy [%sexp "Vcs.graph", { repo_root : Repo_root.t }])
;;

let set_user_name (t : < Trait.config ; .. > t) ~repo_root ~user_name =
  t#set_user_name ~repo_root ~user_name
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.set_user_name", { repo_root : Repo_root.t; user_name : User_name.t }])
;;

let set_user_email (t : < Trait.config ; .. > t) ~repo_root ~user_email =
  t#set_user_email ~repo_root ~user_email
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.set_user_email", { repo_root : Repo_root.t; user_email : User_email.t }])
;;

let show_file_at_rev (t : < Trait.show ; .. > t) ~repo_root ~rev ~path =
  t#show_file_at_rev ~repo_root ~rev ~path
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
      (t : < Trait.git ; .. >)
      ~repo_root
      ~args
      ~f
  =
  let cwd = Repo_root.append repo_root run_in_subdir in
  t#git ?env () ~cwd ~args ~f
;;

let git ?env ?run_in_subdir vcs ~repo_root ~args ~f =
  non_raising_git ?env ?run_in_subdir vcs ~repo_root ~args ~f:(fun output ->
    match f output with
    | ok -> Ok ok
    | exception exn -> Error (Err.of_exn exn))
  |> of_result ~step:(lazy (make_git_err_step ?env ?run_in_subdir ~repo_root ~args ()))
;;

module Private = struct
  let git = non_raising_git
  let make_git_err_step = make_git_err_step
end
