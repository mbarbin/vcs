(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** A log is a complete listing of the structure of the dag.

    It contains all the commits, along with the parents of each commit. *)

module Line : sig
  type t (** @canonical Volgo.Vcs.Log.Line.t *)

  val create : rev:Rev.t -> parents:Rev.t list -> t
  val to_dyn : t -> Dyn.t
  val sexp_of_t : t -> Sexp.t
  val equal : t -> t -> bool
  val rev : t -> Rev.t
  val parents : t -> Rev.t list
  val parent_count : t -> int
end

type t = Line.t list

val to_dyn : t -> Dyn.t
val sexp_of_t : t -> Sexp.t
val equal : t -> t -> bool

(** {1 Accessors} *)

(** Return the list of all init commits. *)
val roots : t -> Rev.t list
