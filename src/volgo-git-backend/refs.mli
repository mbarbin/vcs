(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

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

  val to_dyn : t -> Dyn.t
  val sexp_of_t : t -> Sexp.t
  val equal : t -> t -> bool
  val parse_exn : line:string -> t
end

(** Parsing the output of ["git show-ref --dereference"]. *)
val parse_lines_exn : lines:string list -> Vcs.Refs.t
