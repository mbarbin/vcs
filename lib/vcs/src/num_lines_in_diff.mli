(*_******************************************************************************)
(*_  Vcs - a Versatile OCaml Library for Git Interaction                        *)
(*_  Copyright (C) 2024 Mathieu Barbin <mathieu.barbin@gmail.com>               *)
(*_                                                                             *)
(*_  This file is part of Vcs.                                                  *)
(*_                                                                             *)
(*_  Vcs is free software; you can redistribute it and/or modify it under       *)
(*_  the terms of the GNU Lesser General Public License as published by the     *)
(*_  Free Software Foundation either version 3 of the License, or any later     *)
(*_  version, with the LGPL-3.0 Linking Exception.                              *)
(*_                                                                             *)
(*_  Vcs is distributed in the hope that it will be useful, but WITHOUT ANY     *)
(*_  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*_  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*_  the file `NOTICE.md` at the root of this repository for more details.      *)
(*_                                                                             *)
(*_  You should have received a copy of the GNU Lesser General Public License   *)
(*_  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*_  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*_******************************************************************************)

(** Number of lines involved in a change.

    Git returns this as a pair of positive integers, which are the number of
    insertions and number of deletions. Both are a positive or null integer counting
    a number of lines. *)

type t =
  { insertions : int
  ; deletions : int
  }
[@@deriving compare, equal, sexp_of]

val zero : t
val ( + ) : t -> t -> t
val sum : t list -> t
val is_zero : t -> bool

(** Returns a short string suitable for human consumption.
    Some examples: [["0"; "+100"; "-15"; "+1,999, -13,898"]]. *)
val to_string_hum : t -> string

(** The addition of the insertions and deletions. *)
val total : t -> int
