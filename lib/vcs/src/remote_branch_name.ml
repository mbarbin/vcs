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

module T = struct
  [@@@coverage off]

  type t =
    { remote_name : Remote_name.t
    ; branch_name : Branch_name.t
    }
  [@@deriving compare, hash, sexp_of]
end

include T
include Comparable.Make (T)

let to_string { remote_name; branch_name } =
  Printf.sprintf
    "%s/%s"
    (Remote_name.to_string remote_name)
    (Branch_name.to_string branch_name)
;;

let of_string str =
  match String.lsplit2 str ~on:'/' with
  | None -> Error (`Msg (Printf.sprintf "%S: invalid remote_branch_name" str))
  | Some (remote, branch) ->
    let%bind.Result remote_name = Remote_name.of_string remote in
    let%map.Result branch_name = Branch_name.of_string branch in
    { remote_name; branch_name }
;;

let v str =
  match str |> of_string with
  | Ok t -> t
  | Error (`Msg m) -> invalid_arg m
;;
