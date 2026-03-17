(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

open! Stdlib_compat
include module type of StringLabels

val to_dyn : t -> Dyn.t
val sexp_of_t : t -> Sexp.t
val to_string : string -> string
val chop_prefix : string -> prefix:string -> string option
val chop_suffix : string -> suffix:string -> string option
val is_empty : string -> bool
val lsplit2 : string -> on:char -> (string * string) option
val rsplit2 : string -> on:char -> (string * string) option
val split_lines : string -> string list
val split : string -> on:char -> string list
val strip : string -> string
val uncapitalize : string -> string
