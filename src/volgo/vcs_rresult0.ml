(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type t = [ `Vcs of Err.t ]

let sexp_of_t (`Vcs err) =
  Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "Vcs"; Err.sexp_of_t err ]
;;

let of_err err = `Vcs err
let to_err (`Vcs err) = err
