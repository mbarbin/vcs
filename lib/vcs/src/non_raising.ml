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

module type M = Vcs_interface.Error_S
module type S = Vcs_interface.S

module Make (M : M) :
  S with type 'a t := 'a Vcs0.t and type 'a result := ('a, M.err) Result.t = struct
  let init vcs ~path =
    match Vcs0.init vcs ~path with
    | r -> Ok r
    | exception Exn0.E err -> Error (M.map_error err)
  ;;

  let add vcs ~repo_root ~path =
    match Vcs0.add vcs ~repo_root ~path with
    | r -> Ok r
    | exception Exn0.E err -> Error (M.map_error err)
  ;;

  let commit vcs ~repo_root ~commit_message =
    match Vcs0.commit vcs ~repo_root ~commit_message with
    | r -> Ok r
    | exception Exn0.E err -> Error (M.map_error err)
  ;;

  let ls_files vcs ~repo_root ~below =
    match Vcs0.ls_files vcs ~repo_root ~below with
    | r -> Ok r
    | exception Exn0.E err -> Error (M.map_error err)
  ;;

  let show_file_at_rev vcs ~repo_root ~rev ~path =
    match Vcs0.show_file_at_rev vcs ~repo_root ~rev ~path with
    | r -> Ok r
    | exception Exn0.E err -> Error (M.map_error err)
  ;;

  let load_file vcs ~path =
    match Vcs0.load_file vcs ~path with
    | r -> Ok r
    | exception Exn0.E err -> Error (M.map_error err)
  ;;

  let save_file ?perms vcs ~path ~file_contents =
    match Vcs0.save_file ?perms vcs ~path ~file_contents with
    | r -> Ok r
    | exception Exn0.E err -> Error (M.map_error err)
  ;;

  let rename_current_branch vcs ~repo_root ~to_ =
    match Vcs0.rename_current_branch vcs ~repo_root ~to_ with
    | r -> Ok r
    | exception Exn0.E err -> Error (M.map_error err)
  ;;

  let name_status vcs ~repo_root ~changed =
    match Vcs0.name_status vcs ~repo_root ~changed with
    | r -> Ok r
    | exception Exn0.E err -> Error (M.map_error err)
  ;;

  let num_status vcs ~repo_root ~changed =
    match Vcs0.num_status vcs ~repo_root ~changed with
    | r -> Ok r
    | exception Exn0.E err -> Error (M.map_error err)
  ;;

  let log vcs ~repo_root =
    match Vcs0.log vcs ~repo_root with
    | r -> Ok r
    | exception Exn0.E err -> Error (M.map_error err)
  ;;

  let refs vcs ~repo_root =
    match Vcs0.refs vcs ~repo_root with
    | r -> Ok r
    | exception Exn0.E err -> Error (M.map_error err)
  ;;

  let tree vcs ~repo_root =
    match Vcs0.tree vcs ~repo_root with
    | r -> Ok r
    | exception Exn0.E err -> Error (M.map_error err)
  ;;

  let rev_parse vcs ~repo_root ~arg =
    match Vcs0.rev_parse vcs ~repo_root ~arg with
    | r -> Ok r
    | exception Exn0.E err -> Error (M.map_error err)
  ;;

  let set_user_name vcs ~repo_root ~user_name =
    match Vcs0.set_user_name vcs ~repo_root ~user_name with
    | r -> Ok r
    | exception Exn0.E err -> Error (M.map_error err)
  ;;

  let set_user_email vcs ~repo_root ~user_email =
    match Vcs0.set_user_email vcs ~repo_root ~user_email with
    | r -> Ok r
    | exception Exn0.E err -> Error (M.map_error err)
  ;;

  let git ?env ?run_in_subdir vcs ~repo_root ~args ~f =
    match
      Vcs0.Private.git ?env ?run_in_subdir vcs ~repo_root ~args ~f:(fun output ->
        f output |> Result.map_error ~f:M.to_error)
    with
    | Ok t -> Ok t
    | Error error ->
      Error
        (M.map_error
           (Err.init
              error
              ~step:
                [%sexp
                  "Vcs.git"
                  , { repo_root : Repo_root.t
                    ; run_in_subdir : Path_in_repo.t option
                    ; env : string array option
                    ; args : string list
                    }]))
  ;;
end
