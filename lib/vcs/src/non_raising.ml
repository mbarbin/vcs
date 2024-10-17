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

module type M = Vcs_interface.Error_S
module type S = Vcs_interface.S

module Make (M : M) :
  S with type 'a t := 'a Vcs0.t and type 'a result := ('a, M.err) Result.t = struct
  let try_with f =
    match f () with
    | r -> Ok r
    | exception Exn0.E err -> Error (M.map_error err)
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
        f output |> Result.map_error ~f:M.to_error)
    with
    | Ok t -> Ok t
    | Error error ->
      Error
        (M.map_error
           (Err.init
              error
              ~step:
                (Vcs0.Private.make_git_err_step ?env ?run_in_subdir ~repo_root ~args ())))
  ;;
end
