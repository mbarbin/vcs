(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

module type S = sig
  type t

  val compare : t -> t -> int
  val equal : t -> t -> bool
  val hash : t -> int
  val seeded_hash : int -> t -> int
  val sexp_of_t : t -> Sexp.t
  val to_dyn : t -> Dyn.t
end

module String_impl : S with type t = string
