(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type t = Error.t

let sexp_of_t = Error.sexp_of_t
let of_err = Vcs_err.to_error
let to_err = Vcs_err.of_error
