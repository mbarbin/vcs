(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

include module type of ListLabels

val sexp_of_t : ('a -> Sexp.t) -> 'a t -> Sexp.t
val concat_map : 'a list -> f:('a -> 'b list) -> 'b list
val count : 'a list -> f:('a -> bool) -> int
val dedup_and_sort : 'a list -> compare:('a -> 'a -> int) -> 'a list
val filter_opt : 'a option list -> 'a list
val find : 'a list -> f:('a -> bool) -> 'a option
val find_map : 'a list -> f:('a -> 'b option) -> 'b option
val fold : 'a list -> init:'b -> f:('b -> 'a -> 'b) -> 'b
val hd : 'a list -> 'a option
val iter : 'a list -> f:('a -> unit) -> unit
val map : 'a list -> f:('a -> 'b) -> 'b list
val mapi : 'a list -> f:(int -> 'a -> 'b) -> 'b list
val sort : 'a list -> compare:('a -> 'a -> int) -> 'a list
