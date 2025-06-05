(*_******************************************************************************)
(*_  Volgo - a Versatile OCaml Library for Git Operations                       *)
(*_  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
(*_                                                                             *)
(*_  This file is part of Volgo.                                                *)
(*_                                                                             *)
(*_  Volgo is free software; you can redistribute it and/or modify it under     *)
(*_  the terms of the GNU Lesser General Public License as published by the     *)
(*_  Free Software Foundation either version 3 of the License, or any later     *)
(*_  version, with the LGPL-3.0 Linking Exception.                              *)
(*_                                                                             *)
(*_  Volgo is distributed in the hope that it will be useful, but WITHOUT ANY   *)
(*_  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*_  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*_  the file `NOTICE.md` at the root of this repository for more details.      *)
(*_                                                                             *)
(*_  You should have received a copy of the GNU Lesser General Public License   *)
(*_  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*_  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*_******************************************************************************)

module type S = sig
  (** This is a reduced interface for a vector of bits as used by [vcs].

      We're experimenting with different implementations based on third-party
      libraries. *)

  type t

  (** Print the bits of [t] with the bit 0 to the left. *)
  val sexp_of_t : t -> Sexplib0.Sexp.t

  (** [create ~len value] creates a new vector with [len] bits initialized to
      [value]. *)
  val create : len:int -> bool -> t

  (** Return the number of bits in [t]. *)
  val length : t -> int

  (** Set the i-th bit of [t] to [true]. *)
  val set : t -> int -> unit

  (** Set the i-th bit of [t] to [false]. *)
  val clear : t -> int -> unit

  val get : t -> int -> bool

  (** Set all bits of [t] to [false]. *)
  val clear_all : t -> unit

  (** Return a fresh copy of [t]. *)
  val copy : t -> t

  (** {1 In place bitwise operations} *)

  val bitwise_and_in_place : dst:t -> t -> t -> unit
end
