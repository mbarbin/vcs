(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Interaction                        *)
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

module T = struct
  type t =
    { insertions : int
    ; deletions : int
    }
  [@@deriving compare, equal, sexp_of]

  let zero = { insertions = 0; deletions = 0 }

  let ( + ) t1 t2 =
    { insertions = t1.insertions + t2.insertions
    ; deletions = t1.deletions + t2.deletions
    }
  ;;
end

include T

let sum ts = List.sum (module T) ts ~f:Fn.id

let to_string_hum { insertions; deletions } =
  let int_hum i = Int.to_string_hum ~delimiter:',' i in
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

let total { insertions; deletions } = Int.( + ) insertions deletions
let is_zero { insertions; deletions } = insertions = 0 && deletions = 0
