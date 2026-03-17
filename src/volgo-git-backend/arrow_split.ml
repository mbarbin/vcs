(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type t =
  | Empty
  | One of string
  | Two of string * string
  | More_than_two

let to_dyn = function
  | Empty -> Dyn.variant "Empty" []
  | One s -> Dyn.variant "One" [ Dyn.string s ]
  | Two (l, r) -> Dyn.variant "Two" [ Dyn.string l; Dyn.string r ]
  | More_than_two -> Dyn.variant "More_than_two" []
;;

let sep_len = 4

let is_sep_at str ~pos ~len =
  pos + sep_len <= len
  && Char.equal (String.unsafe_get str pos) ' '
  && Char.equal (String.unsafe_get str (pos + 1)) '='
  && Char.equal (String.unsafe_get str (pos + 2)) '>'
  && Char.equal (String.unsafe_get str (pos + 3)) ' '
;;

let split str =
  let len = String.length str in
  let rec find_next start =
    if start + sep_len > len
    then None
    else if is_sep_at str ~pos:start ~len
    then Some start
    else find_next (start + 1)
  in
  match find_next 0 with
  | None -> if String.is_empty str then Empty else One str
  | Some first_pos ->
    let after_first = first_pos + sep_len in
    (match find_next after_first with
     | Some _ -> More_than_two
     | None ->
       let left = String.sub str ~pos:0 ~len:first_pos in
       let right = String.sub str ~pos:after_first ~len:(len - after_first) in
       Two (left, right))
;;
