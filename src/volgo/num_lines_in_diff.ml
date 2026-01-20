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

module T = struct
  type t =
    { insertions : int
    ; deletions : int
    }

  let to_dyn { insertions; deletions } =
    Dyn.Record [ "insertions", Dyn.Int insertions; "deletions", Dyn.Int deletions ]
  ;;

  let sexp_of_t t = Dyn.to_sexp (to_dyn t)

  let compare t ({ insertions; deletions } as t2) =
    if phys_equal t t2
    then 0
    else (
      match Int.compare t.insertions insertions with
      | 0 -> Int.compare t.deletions deletions
      | n -> n)
  ;;

  let equal a b = compare a b = 0
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
