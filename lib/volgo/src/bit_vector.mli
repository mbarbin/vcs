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

(* CR mbarbin: On second thought, what I wish to do now to make it easier to
   test different libraries is to keep this module as a thin wrapper, and simply
   use third-party libraries in its implementation.

   This should make the PR to experiment with fast_bitvector and bitv easier to
   review and their integration should be local to the implementation of this
   modue only.

   And we can keep (and extend) the test for the layer that we do indeed use.

   That being said, we shall be free to rename things and make the API look a
   little closer to whichever library we like best and/or combining ideas from
   both. *)

(** A naive implementation of mutable bit vectors.

    At some point, with some benchmarks for sanity checks, it seems desirable to
    switch to a less naive implementation. *)

type t [@@deriving sexp_of]

val create : len:int -> bool -> t
val length : t -> int
val set : t -> int -> bool -> unit
val get : t -> int -> bool
val reset : t -> bool -> unit
val copy : t -> t

(** {1 In place bitwise operations} *)

val bw_and_in_place : mutates:t -> t -> unit
