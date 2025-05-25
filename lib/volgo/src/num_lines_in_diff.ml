(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
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
  type t =
    { insertions : int
    ; deletions : int
    }
  [@@deriving sexp_of]

  let compare =
    (fun a__001_ b__002_ ->
       if a__001_ == b__002_
       then 0
       else (
         match compare_int a__001_.insertions b__002_.insertions with
         | 0 -> compare_int a__001_.deletions b__002_.deletions
         | n -> n)
     : t -> t -> int)
  ;;

  let equal =
    (fun a__003_ b__004_ ->
       if a__003_ == b__004_
       then true
       else
         equal_int a__003_.insertions b__004_.insertions
         && equal_int a__003_.deletions b__004_.deletions
     : t -> t -> bool)
  ;;

  let zero = { insertions = 0; deletions = 0 }

  let ( + ) t1 t2 =
    { insertions = t1.insertions + t2.insertions
    ; deletions = t1.deletions + t2.deletions
    }
  ;;
end

include T

let sum ts = List.fold ts ~init:T.zero ~f:T.( + )

let to_string_hum { insertions; deletions } =
  let int_hum i = Int.to_string_hum i in
  match
    [ (if insertions > 0 then Some ("+" ^ int_hum insertions) else None)
    ; (if deletions > 0 then Some ("-" ^ int_hum deletions) else None)
    ]
    |> List.filter_opt
  with
  | [] -> "0"
  | [ hd ] -> hd
  | [ a; b ] -> a ^ ", " ^ b
  | _ :: _ :: _ :: _ -> assert false
;;

let total { insertions; deletions } = Int.add insertions deletions
let is_zero { insertions; deletions } = insertions = 0 && deletions = 0
