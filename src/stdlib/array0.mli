(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

include module type of ArrayLabels

val to_list_mapi : 'a t -> f:(int -> 'a -> 'b) -> 'b list
val sexp_of_t : ('a -> Sexp.t) -> 'a t -> Sexp.t
val create : len:int -> 'a -> 'a array
val filter_mapi : 'a array -> f:(int -> 'a -> 'b option) -> 'b array
val rev : 'a array -> 'a array
val sort : 'a array -> compare:('a -> 'a -> int) -> unit
