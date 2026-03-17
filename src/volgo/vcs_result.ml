(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type err = Err.t

let sexp_of_err = Err.sexp_of_t

type 'a t = ('a, err) Result.t

let sexp_of_t sexp_of_a t = Result.sexp_of_t sexp_of_a sexp_of_err t

module Non_raising_M = struct
  type t = err

  let sexp_of_t = Err.sexp_of_t
  let to_err t = t
  let of_err t = t
end

include Non_raising.Make (Non_raising_M)
