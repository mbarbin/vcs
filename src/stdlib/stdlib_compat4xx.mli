(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** This file is used when compiling with older versions of OCaml where the
    [hash] and [seeded_hash] functions were not available in the stdlib.

    It is made available as [stdlib_compat.ml] via a build rule configured in
    [dune] which is conditioned on the value of the [ocaml_version] variable. *)

module Int : sig
  include module type of Int

  val hash : t -> int
  val seeded_hash : int -> int -> int
end

module ListLabels : sig
  include module type of ListLabels

  val is_empty : _ t -> bool
end

module String : sig
  include module type of String

  val hash : t -> int
  val seeded_hash : int -> string -> int
end

module StringLabels : sig
  include module type of StringLabels

  val hash : t -> int
  val seeded_hash : int -> string -> int
end
