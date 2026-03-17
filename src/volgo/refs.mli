(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Capturing the information related to git refs.

    In this file we represent the output of the [git show-ref] command. In
    particular we represent the location of all known local branches heads,
    remote branches heads and tags.

    It is worth noting that the location of the remote branches is the state of
    the remote branches as they are currently known locally. *)

module Line : sig
  (** @canonical Volgo.Vcs.Refs.Line.t *)
  type t =
    { rev : Rev.t
    ; ref_kind : Ref_kind.t
    }

  val to_dyn : t -> Dyn.t
  val sexp_of_t : t -> Sexp.t
  val equal : t -> t -> bool
end

type t = Line.t list

val to_dyn : t -> Dyn.t
val sexp_of_t : t -> Sexp.t
val equal : t -> t -> bool

(** {1 Accessors} *)

val tags : t -> Tag_name.t list
val local_branches : t -> Branch_name.t list
val remote_branches : t -> Remote_branch_name.t list
