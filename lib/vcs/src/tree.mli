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

(** Building an in-memory representation of a git tree, for queries about
    history contents.

    This data structure only contains the nodes, as well as the location of
    known branches (local and remotes) and tags.

    The design is such that it is easy to add new nodes, and to compute the diff
    of what needs to be sent to a process holding such a value in memory to
    complete its view of a tree. *)

type t [@@deriving sexp_of]

(** create an empty tree that has no nodes. *)
val create : unit -> t

(** [add t log] add to [t] all the nodes from the tree log. This is idempotent if
    [t] already knows all of the nodes. *)
val add_nodes : t -> log:Log.t -> unit

module Node_kind : sig
  type 'index t = private
    | Root of { rev : Rev.t }
    | Commit of
        { rev : Rev.t
        ; parent : 'index
        }
    | Merge of
        { rev : Rev.t
        ; parent1 : 'index
        ; parent2 : 'index
        }
  [@@deriving equal, sexp_of]

  val rev : _ t -> Rev.t
  val map_index : 'a t -> f:('a -> 'b) -> 'b t
end

module Node : sig
  type tree := t
  type t [@@deriving equal, sexp_of]

  val rev : tree -> t -> Rev.t
  val parents : tree -> t -> t list
  val node_kind : tree -> t -> t Node_kind.t
  val refs : tree -> t -> Ref_kind.t list

  module Descendance : sig
    (** Descendance is a relation between 2 nodes of the tree. Matching on it is
        useful for example when considering the status of a branch head with
        respect to its upstream counterpart. *)
    type t =
      | Same
      | Strict_ancestor
      | Strict_descendant
      | Unrelated
    [@@deriving equal, enumerate, hash, sexp_of]
  end

  val descendance : tree -> t -> t -> Descendance.t
end

(** {1 Refs} *)

(** List known refs. *)
val refs : t -> Refs.t

val set_refs : t -> refs:Refs.t -> unit
val set_ref : t -> rev:Rev.t -> ref_kind:Ref_kind.t -> unit

(** Find a ref if it is present. *)
val find_ref : t -> ref_kind:Ref_kind.t -> Node.t option

(** {1 Revisions} *)

(** Find the node pointed by the rev if any. *)
val find_rev : t -> rev:Rev.t -> Node.t option

(** Tell if a revision points to a valid node of the tree. *)
val mem_rev : t -> rev:Rev.t -> bool

(** {1 Roots & Tips} *)

(** Return the list of nodes that do not have any parents. *)
val roots : t -> Node.t list

(** Return the list of nodes that do not have any children. *)
val tips : t -> Node.t list

(** {1 Ancestors} *)

(** [is_strict_ancestor t ~ancestor:a ~descendant:b] returns [true] iif there
    exists a non empty path that leads from [a] to [b]. By definition, any node
    is not a strict ancestor of itself. .*)
val is_strict_ancestor : t -> ancestor:Node.t -> descendant:Node.t -> bool

(** [is_ancestor_or_equal t ~ancestor:a ~descendant:b] returns [true] iif there
    [a] is a strict ancestor of [b] or if [a] is equal to [b]. *)
val is_ancestor_or_equal : t -> ancestor:Node.t -> descendant:Node.t -> bool

(** {1 Log} *)

val log : t -> Log.t

(** {1 Subtree} *)

module Subtree : sig
  type t =
    { log : Log.t
    ; refs : Refs.t
    }
  [@@deriving sexp_of]

  val is_empty : t -> bool
end

val subtrees : t -> Subtree.t list
val of_subtree : Subtree.t -> t

(** {1 Summary} *)

module Summary : sig
  type t [@@deriving sexp_of]
end

(** Print a summary for use in expect test and quick exploratory tests *)
val summary : t -> Summary.t
