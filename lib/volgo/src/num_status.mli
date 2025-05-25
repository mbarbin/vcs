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

module Key : sig
  type t =
    | One_file of Path_in_repo.t
    | Two_files of
        { src : Path_in_repo.t
        ; dst : Path_in_repo.t
        }

  include Container_key.S with type t := t
end

module Change : sig
  module Num_stat : sig
    (** The number of lines in diff is not always given by git - indeed
        sometimes the line of output for this file contains dash '-'
        characters in lieu of the number of insertions or deletions. According
        to [man git diff] this happens for binary files. *)
    type t =
      | Num_lines_in_diff of Num_lines_in_diff.t
      | Binary_file
    [@@deriving sexp_of]

    val equal : t -> t -> bool
  end

  type t =
    { key : Key.t
    ; num_stat : Num_stat.t
    }
  [@@deriving sexp_of]

  val equal : t -> t -> bool
end

type t = Change.t list [@@deriving sexp_of]

module Changed : sig
  (** Specifies which {!type:Num_status.t} we want to compute. *)
  type t = Name_status.Changed.t =
    | Between of
        { src : Rev.t
        ; dst : Rev.t
        }
  [@@deriving sexp_of]

  val equal : t -> t -> bool
end
