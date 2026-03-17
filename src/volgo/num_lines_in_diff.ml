(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

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
