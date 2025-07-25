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

(** This file is used when compiling with older versions of OCaml where the
    [hash] and [seeded_hash] functions were not available in the stdlib.

    It is included to the [import] file thanks to a build rule configured in
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
