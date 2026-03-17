(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module type M = Error_intf.S
module type S = Vcs_intf.S

module Make (M : M) :
  S with type 'a t := 'a Vcs0.t and type 'a result := ('a, M.t) Result.t = struct
  let try_with f =
    match f () with
    | r -> Ok r
    | exception Err.E err -> Error (M.of_err err)
  ;;

  let init vcs ~path = try_with (fun () -> Vcs0.init vcs ~path)

  let find_enclosing_repo_root vcs ~from ~store =
    try_with (fun () -> Vcs0.find_enclosing_repo_root vcs ~from ~store)
  ;;

  let find_enclosing_git_repo_root vcs ~from =
    try_with (fun () -> Vcs0.find_enclosing_git_repo_root vcs ~from)
  ;;

  let add vcs ~repo_root ~path = try_with (fun () -> Vcs0.add vcs ~repo_root ~path)

  let commit vcs ~repo_root ~commit_message =
    try_with (fun () -> Vcs0.commit vcs ~repo_root ~commit_message)
  ;;

  let ls_files vcs ~repo_root ~below =
    try_with (fun () -> Vcs0.ls_files vcs ~repo_root ~below)
  ;;

  let show_file_at_rev vcs ~repo_root ~rev ~path =
    try_with (fun () -> Vcs0.show_file_at_rev vcs ~repo_root ~rev ~path)
  ;;

  let load_file vcs ~path = try_with (fun () -> Vcs0.load_file vcs ~path)

  let save_file ?perms vcs ~path ~file_contents =
    try_with (fun () -> Vcs0.save_file ?perms vcs ~path ~file_contents)
  ;;

  let read_dir vcs ~dir = try_with (fun () -> Vcs0.read_dir vcs ~dir)

  let rename_current_branch vcs ~repo_root ~to_ =
    try_with (fun () -> Vcs0.rename_current_branch vcs ~repo_root ~to_)
  ;;

  let name_status vcs ~repo_root ~changed =
    try_with (fun () -> Vcs0.name_status vcs ~repo_root ~changed)
  ;;

  let num_status vcs ~repo_root ~changed =
    try_with (fun () -> Vcs0.num_status vcs ~repo_root ~changed)
  ;;

  let log vcs ~repo_root = try_with (fun () -> Vcs0.log vcs ~repo_root)
  let refs vcs ~repo_root = try_with (fun () -> Vcs0.refs vcs ~repo_root)
  let graph vcs ~repo_root = try_with (fun () -> Vcs0.graph vcs ~repo_root)

  let current_branch vcs ~repo_root =
    try_with (fun () -> Vcs0.current_branch vcs ~repo_root)
  ;;

  let current_branch_opt vcs ~repo_root =
    try_with (fun () -> Vcs0.current_branch_opt vcs ~repo_root)
  ;;

  let current_revision vcs ~repo_root =
    try_with (fun () -> Vcs0.current_revision vcs ~repo_root)
  ;;

  let set_user_name vcs ~repo_root ~user_name =
    try_with (fun () -> Vcs0.set_user_name vcs ~repo_root ~user_name)
  ;;

  let set_user_email vcs ~repo_root ~user_email =
    try_with (fun () -> Vcs0.set_user_email vcs ~repo_root ~user_email)
  ;;

  let git ?env ?run_in_subdir vcs ~repo_root ~args ~f =
    match
      Vcs0.Private.git ?env ?run_in_subdir vcs ~repo_root ~args ~f:(fun output ->
        f output |> Result.map_error ~f:M.to_err)
    with
    | Ok t -> Ok t
    | Error err ->
      Error
        (M.of_err
           (Err.add_context
              err
              [ Err.sexp
                  (Vcs0.Private.make_git_err_step ?env ?run_in_subdir ~repo_root ~args ())
              ]))
  ;;

  let hg ?env ?run_in_subdir vcs ~repo_root ~args ~f =
    match
      Vcs0.Private.hg ?env ?run_in_subdir vcs ~repo_root ~args ~f:(fun output ->
        f output |> Result.map_error ~f:M.to_err)
    with
    | Ok t -> Ok t
    | Error err ->
      Error
        (M.of_err
           (Err.add_context
              err
              [ Err.sexp
                  (Vcs0.Private.make_hg_err_step ?env ?run_in_subdir ~repo_root ~args ())
              ]))
  ;;
end
