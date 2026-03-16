(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

include module type of Option

val sexp_of_t : ('a -> Sexp.t) -> 'a t -> Sexp.t
val iter : 'a t -> f:('a -> unit) -> unit
val map : 'a option -> f:('a -> 'b) -> 'b option
val some_if : bool -> 'a -> 'a option
