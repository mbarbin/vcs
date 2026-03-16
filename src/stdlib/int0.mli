(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

include module type of Int

val sexp_of_t : t -> Sexp.t
val to_dyn : t -> Dyn.t
val incr : int ref -> unit
val max_value : int
val of_string_opt : string -> int option
val to_string_hum : int -> string
