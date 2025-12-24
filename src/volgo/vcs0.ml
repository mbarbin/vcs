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

type +'a t = 'a constraint 'a = < .. >

let create traits = traits

let of_result ~step = function
  | Ok r -> r
  | Error err -> raise (Err.E (Err.add_context err [ Err.sexp (Lazy.force step) ]))
;;

let step_trace fct fields = Sexp.List (Atom fct :: fields)

let load_file (t : < Trait.file_system ; .. > t) ~path =
  t#load_file ~path
  |> of_result
       ~step:
         (lazy
           (step_trace "Vcs.load_file" [ sexp_field (module Absolute_path) "path" path ]))
;;

let save_file ?perms (t : < Trait.file_system ; .. > t) ~path ~file_contents =
  t#save_file ?perms () ~path ~file_contents
  |> of_result
       ~step:
         (lazy
           (step_trace
              "Vcs.save_file"
              [ sexp_field' (Option.sexp_of_t Int.sexp_of_t) "perms" perms
              ; sexp_field (module Absolute_path) "path" path
              ]))
;;

let read_dir (t : < Trait.file_system ; .. > t) ~dir =
  t#read_dir ~dir
  |> of_result
       ~step:
         (lazy
           (step_trace "Vcs.read_dir" [ sexp_field (module Absolute_path) "dir" dir ]))
;;

let add (t : < Trait.add ; .. > t) ~repo_root ~path =
  t#add ~repo_root ~path
  |> of_result
       ~step:
         (lazy
           (step_trace
              "Vcs.add"
              [ sexp_field (module Repo_root) "repo_root" repo_root
              ; sexp_field (module Path_in_repo) "path" path
              ]))
;;

let init (t : < Trait.init ; .. > t) ~path =
  t#init ~path
  |> of_result
       ~step:
         (lazy (step_trace "Vcs.init" [ sexp_field (module Absolute_path) "path" path ]))
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

let current_branch (t : < Trait.current_branch ; .. > t) ~repo_root =
  (match t#current_branch ~repo_root with
   | Error _ as err -> err
   | Ok (Some b) -> Ok b
   | Ok None -> Error (Err.create [ Pp.text "Not currently on any branch." ]))
  |> of_result
       ~step:
         (lazy
           (step_trace
              "Vcs.current_branch"
              [ sexp_field (module Repo_root) "repo_root" repo_root ]))
;;

let current_branch_opt (t : < Trait.current_branch ; .. > t) ~repo_root =
  t#current_branch ~repo_root
  |> of_result
       ~step:
         (lazy
           (step_trace
              "Vcs.current_branch_opt"
              [ sexp_field (module Repo_root) "repo_root" repo_root ])
           [@coverage off])
;;

let current_revision (t : < Trait.current_revision ; .. > t) ~repo_root =
  t#current_revision ~repo_root
  |> of_result
       ~step:
         (lazy
           (step_trace
              "Vcs.current_revision"
              [ sexp_field (module Repo_root) "repo_root" repo_root ]))
;;

let commit
      (t : < Trait.commit ; Trait.current_revision ; .. > t)
      ~repo_root
      ~commit_message
  =
  (let open Result.Monad_syntax in
   let* () = t#commit ~repo_root ~commit_message in
   t#current_revision ~repo_root)
  |> of_result
       ~step:
         (lazy
           (step_trace
              "Vcs.commit"
              [ sexp_field (module Repo_root) "repo_root" repo_root ]))
;;

let ls_files (t : < Trait.ls_files ; .. > t) ~repo_root ~below =
  t#ls_files ~repo_root ~below
  |> of_result
       ~step:
         (lazy
           (step_trace
              "Vcs.ls_files"
              [ sexp_field (module Repo_root) "repo_root" repo_root
              ; sexp_field (module Path_in_repo) "below" below
              ]))
;;

let rename_current_branch (t : < Trait.branch ; .. > t) ~repo_root ~to_ =
  t#rename_current_branch ~repo_root ~to_
  |> of_result
       ~step:
         (lazy
           (step_trace
              "Vcs.rename_current_branch"
              [ sexp_field (module Repo_root) "repo_root" repo_root
              ; sexp_field (module Branch_name) "to_" to_
              ]))
;;

let name_status (t : < Trait.name_status ; .. > t) ~repo_root ~changed =
  t#name_status ~repo_root ~changed
  |> of_result
       ~step:
         (lazy
           (step_trace
              "Vcs.name_status"
              [ sexp_field (module Repo_root) "repo_root" repo_root
              ; sexp_field (module Name_status.Changed) "changed" changed
              ]))
;;

let num_status (t : < Trait.num_status ; .. > t) ~repo_root ~changed =
  t#num_status ~repo_root ~changed
  |> of_result
       ~step:
         (lazy
           (step_trace
              "Vcs.num_status"
              [ sexp_field (module Repo_root) "repo_root" repo_root
              ; sexp_field (module Num_status.Changed) "changed" changed
              ]))
;;

let log (t : < Trait.log ; .. > t) ~repo_root =
  t#get_log_lines ~repo_root
  |> of_result
       ~step:
         (lazy
           (step_trace "Vcs.log" [ sexp_field (module Repo_root) "repo_root" repo_root ]))
;;

let refs (t : < Trait.refs ; .. > t) ~repo_root =
  t#get_refs_lines ~repo_root
  |> of_result
       ~step:
         (lazy
           (step_trace "Vcs.refs" [ sexp_field (module Repo_root) "repo_root" repo_root ]))
;;

let graph (t : < Trait.log ; Trait.refs ; .. > t) ~repo_root =
  let graph = Graph.create () in
  (let open Result.Monad_syntax in
   let* log = t#get_log_lines ~repo_root in
   let* refs = t#get_refs_lines ~repo_root in
   Graph.add_nodes graph ~log;
   Graph.set_refs graph ~refs;
   Result.return graph)
  |> of_result
       ~step:
         (lazy
           (step_trace
              "Vcs.graph"
              [ sexp_field (module Repo_root) "repo_root" repo_root ])
           [@coverage off])
;;

let set_user_name (t : < Trait.config ; .. > t) ~repo_root ~user_name =
  t#set_user_name ~repo_root ~user_name
  |> of_result
       ~step:
         (lazy
           (step_trace
              "Vcs.set_user_name"
              [ sexp_field (module Repo_root) "repo_root" repo_root
              ; sexp_field (module User_name) "user_name" user_name
              ]))
;;

let set_user_email (t : < Trait.config ; .. > t) ~repo_root ~user_email =
  t#set_user_email ~repo_root ~user_email
  |> of_result
       ~step:
         (lazy
           (step_trace
              "Vcs.set_user_email"
              [ sexp_field (module Repo_root) "repo_root" repo_root
              ; sexp_field (module User_email) "user_email" user_email
              ]))
;;

let show_file_at_rev (t : < Trait.show ; .. > t) ~repo_root ~rev ~path =
  t#show_file_at_rev ~repo_root ~rev ~path
  |> of_result
       ~step:
         (lazy
           (step_trace
              "Vcs.show_file_at_rev"
              [ sexp_field (module Repo_root) "repo_root" repo_root
              ; sexp_field (module Rev) "rev" rev
              ; sexp_field (module Path_in_repo) "path" path
              ]))
;;

let make_git_err_step ?env ?run_in_subdir ~repo_root ~args () =
  step_trace
    "Vcs.git"
    (List.filter_opt
       [ Some (sexp_field (module Repo_root) "repo_root" repo_root)
       ; Option.map run_in_subdir ~f:(fun run_in_subdir ->
           sexp_field (module Path_in_repo) "run_in_subdir" run_in_subdir)
       ; Option.map env ~f:(fun env ->
           sexp_field' (Array.sexp_of_t String.sexp_of_t) "env" env)
       ; Some (sexp_field' (List.sexp_of_t String.sexp_of_t) "args" args)
       ])
;;

let make_hg_err_step ?env ?run_in_subdir ~repo_root ~args () =
  step_trace
    "Vcs.hg"
    (List.filter_opt
       [ Some (sexp_field (module Repo_root) "repo_root" repo_root)
       ; Option.map run_in_subdir ~f:(fun run_in_subdir ->
           sexp_field (module Path_in_repo) "run_in_subdir" run_in_subdir)
       ; Option.map env ~f:(fun env ->
           sexp_field' (Array.sexp_of_t String.sexp_of_t) "env" env)
       ; Some (sexp_field' (List.sexp_of_t String.sexp_of_t) "args" args)
       ])
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

let non_raising_hg
      ?env
      ?(run_in_subdir = Path_in_repo.root)
      (t : < Trait.hg ; .. >)
      ~repo_root
      ~args
      ~f
  =
  let cwd = Repo_root.append repo_root run_in_subdir in
  t#hg ?env () ~cwd ~args ~f
;;

let git ?env ?run_in_subdir vcs ~repo_root ~args ~f =
  non_raising_git ?env ?run_in_subdir vcs ~repo_root ~args ~f:(fun output ->
    match f output with
    | ok -> Ok ok
    | exception exn -> Error (Err.of_exn exn))
  |> of_result ~step:(lazy (make_git_err_step ?env ?run_in_subdir ~repo_root ~args ()))
;;

let hg ?env ?run_in_subdir vcs ~repo_root ~args ~f =
  non_raising_hg ?env ?run_in_subdir vcs ~repo_root ~args ~f:(fun output ->
    match f output with
    | ok -> Ok ok
    | exception exn -> Error (Err.of_exn exn))
  |> of_result ~step:(lazy (make_hg_err_step ?env ?run_in_subdir ~repo_root ~args ()))
;;

module Private = struct
  let git = non_raising_git
  let make_git_err_step = make_git_err_step
  let hg = non_raising_hg
  let make_hg_err_step = make_hg_err_step
end
