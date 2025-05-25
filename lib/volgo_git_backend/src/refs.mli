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

  include Vcs.Trait.Refs.S with type t := t
end

(** {1 Git output parsing}

    This is exposed for tests and low-level usage. *)

val parse_ref_kind_exn : string -> Vcs.Ref_kind.t

module Dereferenced : sig
  (** A [ref_kind] may appear several times in the lines, in which case it will
      be present both dereferenced and non-dereferenced. Because we want to
      retrieve the revisions each ref is pointed to, we only want to keep the
      dereferenced occurrences.

      We test for this case using the data from [super-master-mind.refs] which
      contains the following lines:

      {v
        f4875717f6cd5481f690c88baad1fb1eff4e1a22 refs/tags/0.0.2
        0d4750ff594236a4bd970e1c90b8bbad80fcadff refs/tags/0.0.2^{}
        d5d13aaed2bd0c2f4a37217a21d703c73b8f38d6 refs/tags/0.0.3
        fc8e67fbc47302b7da682e9a7da626790bb59eaa refs/tags/0.0.3^{}
      v}

      In this input, [0.0.2] and [0.0.3] are non-dereferenced items. The sha
      associated with them are identifiers for the tag objects, rather than the
      commit revisions they point to.

      The dereferenced items are [0.0.2^{}] and [0.0.3^{}], and their sha are
      the commit revisions. *)

  type t =
    { rev : Vcs.Rev.t
    ; ref_kind : Vcs.Ref_kind.t
    ; dereferenced : bool
    }
  [@@deriving sexp_of]

  val equal : t -> t -> bool
  val parse_exn : line:string -> t
end

(** Parsing the output of ["git show-ref --dereference"]. *)
val parse_lines_exn : lines:string list -> Vcs.Refs.t
