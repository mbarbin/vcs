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

module Protocol = struct
  type t =
    | Ssh
    | Https
  [@@deriving compare, equal, enumerate, hash, sexp_of]

  let to_string t ~(platform : Platform.t) =
    match platform, t with
    | GitHub, Ssh -> "git@github.com:"
    | GitHub, Https -> "https://github.com/"
  ;;
end

type t =
  { platform : Platform.t
  ; protocol : Protocol.t
  ; user_handle : User_handle.t
  ; repo_name : Repo_name.t
  }
[@@deriving compare, equal, hash, sexp_of]

let to_string t =
  let { platform; protocol; user_handle; repo_name } = t in
  let protocol = Protocol.to_string protocol ~platform in
  let user_handle = User_handle.to_string user_handle in
  let repo_name = Repo_name.to_string repo_name in
  Printf.sprintf "%s%s/%s.git" protocol user_handle repo_name
;;

let of_string (s : string) : t Or_error.t =
  let open Or_error.Let_syntax in
  match
    List.find_map Platform.all ~f:(fun platform ->
      List.find_map Protocol.all ~f:(fun protocol ->
        let prefix = Protocol.to_string protocol ~platform in
        Option.map (String.chop_prefix s ~prefix) ~f:(fun rest ->
          let%bind user_handle, rest =
            String.lsplit2 rest ~on:'/'
            |> Result.of_option ~error:(Error.of_string "missing user handle")
          in
          let%bind repo_name =
            String.chop_suffix rest ~suffix:".git"
            |> Result.of_option ~error:(Error.of_string "missing .git suffix")
          in
          let%bind user_handle = User_handle.of_string user_handle in
          let%bind repo_name = Repo_name.of_string repo_name in
          return { platform; protocol; user_handle; repo_name })))
  with
  | Some (Ok _ as ok) -> ok
  | Some (Error e) ->
    Or_error.error_s [%sexp "Invalid url", { url = (s : string) }, (e : Error.t)]
  | None -> Or_error.error_s [%sexp "Invalid url", { url = (s : string) }]
;;
