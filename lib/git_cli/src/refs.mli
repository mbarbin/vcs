(*_******************************************************************************)
(*_  Vcs - a versatile OCaml library for Git interaction                        *)
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

(** A provider implementation for {!module:Vcs.Trait.Refs}. *)

module Make (Runtime : Runtime.S) : sig
  type t = Runtime.t

  include Vcs.Trait.Refs.S with type t := t
end

(** {1 Git output parsing}

    This is exposed for tests and low-level usage. *)

module Dereferenced : sig
  type t =
    { rev : Vcs.Rev.t
    ; ref_kind : Vcs.Ref_kind.t
    ; dereferenced : bool
    }
  [@@deriving equal, sexp_of]

  val parse_ref_kind_exn : string -> Vcs.Ref_kind.t
  val parse_exn : line:string -> t
end

(** Parsing the output of ["git show-ref --dereference"]. *)
val parse_lines_exn : lines:string list -> Vcs.Refs.t
