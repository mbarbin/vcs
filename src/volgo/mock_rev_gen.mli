(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Creating mock revisions for use in expect tests. *)

type t

val sexp_of_t : t -> Sexp.t
val create : name:string -> t

(** This is the main function provided by the module. Given a state, return a
    {!Vcs.Rev.t} that will be deterministic given the number of times {!next}
    has been called on that generator. *)
val next : t -> Rev.t
