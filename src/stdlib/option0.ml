(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

include Option

let sexp_of_t = Sexplib0.Sexp_conv.sexp_of_option
let iter t ~f = iter f t
let map t ~f = map f t
let some_if cond a = if cond then Some a else None
