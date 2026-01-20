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

type t =
  | Empty
  | One of string
  | Two of string * string
  | More_than_two

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
