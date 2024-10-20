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

[@@@coverage off]

type t =
  { remote_name : Remote_name.t
  ; branch_name : Branch_name.t
  }
[@@deriving sexp_of]

let compare =
  (fun a__001_ b__002_ ->
     if Stdlib.( == ) a__001_ b__002_
     then 0
     else (
       match Remote_name.compare a__001_.remote_name b__002_.remote_name with
       | 0 -> Branch_name.compare a__001_.branch_name b__002_.branch_name
       | n -> n)
   : t -> t -> int)
;;

let equal =
  (fun a__003_ b__004_ ->
     if Stdlib.( == ) a__003_ b__004_
     then true
     else
       Stdlib.( && )
         (Remote_name.equal a__003_.remote_name b__004_.remote_name)
         (Branch_name.equal a__003_.branch_name b__004_.branch_name)
   : t -> t -> bool)
;;

[@@@coverage on]

let seeded_hash = (Stdlib.Hashtbl.seeded_hash : int -> t -> int)
let hash = (Stdlib.Hashtbl.hash : t -> int)

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
    let ( let* ) = Stdlib.Result.bind in
    let* remote_name = Remote_name.of_string remote in
    let* branch_name = Branch_name.of_string branch in
    Result.return { remote_name; branch_name }
;;

let v str =
  match str |> of_string with
  | Ok t -> t
  | Error (`Msg m) -> invalid_arg m
;;
