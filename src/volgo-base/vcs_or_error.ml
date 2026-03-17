(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type err = Vcs_or_error0.t

let sexp_of_err = Vcs_or_error0.sexp_of_t

type 'a t = ('a, err) Result.t

let sexp_of_t sexp_of_a t = Result.sexp_of_t sexp_of_a sexp_of_err t

include Vcs.Non_raising.Make (Vcs_or_error0)
