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

module Make (Runtime : Runtime.S) : sig
  type t = Runtime.t

  include Vcs.Trait.Name_status.S with type t := t
end

(** {1 Git output parsing}

    This is exposed for tests and low-level usage. *)

module Diff_status : sig
  type t =
    [ `A
    | `D
    | `M
    | `R
    | `T
    | `C
    | `U
    | `Q
    | `I
    | `Question_mark
    | `Bang
    | `X
    | `Not_supported
    ]

  val to_dyn : t -> Dyn.t
  val sexp_of_t : t -> Sexp.t
  val parse_exn : string -> t
end

(** Parsing the output of ["git diff --name-status REV..REV"]. *)
val parse_lines_exn : lines:string list -> Vcs.Name_status.t

(** Parse only one line. Exposed for tests. *)
val parse_line_exn : line:string -> Vcs.Name_status.Change.t
