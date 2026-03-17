(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* Some functions are copied from [Base] version [v0.17] which is released
   under MIT and may be found at [https://github.com/janestreet/base].

   See [volgo_stdlib.ml] for the full MIT license notice from Jane Street.

   When this is the case, we clearly indicate it next to the copied function. *)

open! Stdlib_compat
module Char = Char0
include StringLabels

let to_dyn = Dyn.string
let sexp_of_t = Sexplib0.Sexp_conv.sexp_of_string
let to_string t = t

let chop_prefix t ~prefix =
  if starts_with ~prefix t
  then (
    let prefix_len = length prefix in
    Some (sub t ~pos:prefix_len ~len:(length t - prefix_len)))
  else None
;;

let chop_suffix t ~suffix =
  if ends_with ~suffix t
  then Some (sub t ~pos:0 ~len:(length t - length suffix))
  else None
;;

let is_empty t = length t = 0

let lsplit2 t ~on =
  match index_from_opt t 0 on with
  | None -> None
  | Some i -> Some (sub t ~pos:0 ~len:i, sub t ~pos:(i + 1) ~len:(length t - i - 1))
;;

let rsplit2 t ~on =
  let len = length t in
  match rindex_from_opt t (len - 1) on with
  | None -> None
  | Some i -> Some (sub t ~pos:0 ~len:i, sub t ~pos:(i + 1) ~len:(len - i - 1))
;;

(* The function [split_lines] below was copied from [Base.String0.split_lines]
   version [v0.17] which is released under MIT and may be found at
   [https://github.com/janestreet/base].

   The changes we made were minimal:

   - Changed references to [Char0] to [Char].

   See notice at the top of the file and project global notice for licensing
   information. *)

let split_lines =
  let back_up_at_newline ~t ~pos ~eol =
    pos := !pos - if !pos > 0 && Char.equal t.[!pos - 1] '\r' then 2 else 1;
    eol := !pos + 1
  in
  fun t ->
    let n = length t in
    if n = 0
    then []
    else (
      (* Invariant: [-1 <= pos < eol]. *)
      let pos = ref (n - 1) in
      let eol = ref n in
      let ac = ref [] in
      (* We treat the end of the string specially, because if the string ends with a
         newline, we don't want an extra empty string at the end of the output. *)
      if Char.equal t.[!pos] '\n' then back_up_at_newline ~t ~pos ~eol;
      while !pos >= 0 do
        if not (Char.equal t.[!pos] '\n')
        then decr pos
        else (
          (* Because [pos < eol], we know that [start <= eol]. *)
          let start = !pos + 1 in
          ac := sub t ~pos:start ~len:(!eol - start) :: !ac;
          back_up_at_newline ~t ~pos ~eol)
      done;
      sub t ~pos:0 ~len:!eol :: !ac)
;;

(* ---------------------------------------------------------------------------- *)

let split t ~on = split_on_char ~sep:on t
let strip = trim
let uncapitalize = uncapitalize_ascii
