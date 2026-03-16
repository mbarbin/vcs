(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

include module type of Result

module Syntax : sig
  (*_ This is in the stdlib but only since [5.4]. We export it here to support
    older versions. *)
  val ( let* ) : ('a, 'e) t -> ('a -> ('b, 'e) t) -> ('b, 'e) t
end

val sexp_of_t : ('a -> Sexp.t) -> ('b -> Sexp.t) -> ('a, 'b) Result.t -> Sexp.t
val map : ('a, 'e) Result.t -> f:('a -> 'b) -> ('b, 'e) Result.t
val map_error : ('a, 'e1) Result.t -> f:('e1 -> 'e2) -> ('a, 'e2) Result.t
val of_option : 'a option -> error:'e -> ('a, 'e) Result.t
val return : 'a -> ('a, _) Result.t
