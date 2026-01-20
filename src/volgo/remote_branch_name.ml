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

[@@@coverage off]

type t =
  { remote_name : Remote_name.t
  ; branch_name : Branch_name.t
  }

let to_dyn { remote_name; branch_name } =
  Dyn.record
    [ "remote_name", Remote_name.to_dyn remote_name
    ; "branch_name", Branch_name.to_dyn branch_name
    ]
;;

let sexp_of_t t = Dyn.to_sexp (to_dyn t)

let compare t ({ remote_name; branch_name } as t2) =
  if phys_equal t t2
  then 0
  else (
    match Remote_name.compare t.remote_name remote_name with
    | 0 -> Branch_name.compare t.branch_name branch_name
    | n -> n)
;;

let equal a b = compare a b = 0

[@@@coverage on]

let seeded_hash = (Hashtbl.seeded_hash : int -> t -> int)
let hash = (Hashtbl.hash : t -> int)

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
    let open Result.Syntax in
    let* remote_name = Remote_name.of_string remote in
    let* branch_name = Branch_name.of_string branch in
    Result.return { remote_name; branch_name }
;;

let v str =
  match str |> of_string with
  | Ok t -> t
  | Error (`Msg m) -> invalid_arg m
;;
