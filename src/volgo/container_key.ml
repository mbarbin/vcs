(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module type S = sig
  type t

  val compare : t -> t -> int
  val equal : t -> t -> bool
  val hash : t -> int
  val seeded_hash : int -> t -> int
  val sexp_of_t : t -> Sexp.t
  val to_dyn : t -> Dyn.t
end

module String_impl = struct
  type t = string

  let compare = String.compare
  let equal = String.equal
  let hash = String.hash
  let seeded_hash = String.seeded_hash
  let sexp_of_t = sexp_of_string
  let to_dyn = Dyn.string
end
