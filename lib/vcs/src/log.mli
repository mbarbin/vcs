(*_******************************************************************************)
(*_  Vcs - a Versatile OCaml Library for Git Operations                         *)
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

(** A log is a complete listing of the structure of the dag.

    It contains all the commits, along with the parents of each commit. *)

module Line : sig
  type t =
    | Root of { rev : Rev.t }
    | Commit of
        { rev : Rev.t
        ; parent : Rev.t
        }
    | Merge of
        { rev : Rev.t
        ; parent1 : Rev.t
        ; parent2 : Rev.t
        }
  [@@deriving sexp_of]

  val equal : t -> t -> bool
  val rev : t -> Rev.t
end

type t = Line.t list [@@deriving sexp_of]

val equal : t -> t -> bool

(** {1 Accessors} *)

(** Return the list of all init commits. *)
val roots : t -> Rev.t list
