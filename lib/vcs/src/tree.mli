(*_******************************************************************************)
(*_  Vcs - a Versatile OCaml Library for Git Interaction                        *)
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

(** Create an empty tree that has no nodes. *)
val create : unit -> t

(** {1 Initializing the tree}

    This part of the interface is the only part that mutates the tree. The tree
    manipulated in memory needs to know about the nodes and refs that are present in
    the git log.

    The calls to the functions [add_nodes] and [set_refs] are typically handled
    for you by the function [Vcs.tree], however they are exposed if you want to
    manually build trees in more advanced ways (such as incrementally), or for
    testing purposes.

    Adding nodes or refs to a tree does not affect the git repository. These are
    simply operations that needs to be called to feed to [t] the information
    that already exists in the git log. *)

(** [add t ~log] add to [t] all the nodes from the tree log. This is idempotent
    this doesn't add the nodes that if [t] already knows.*)
val add_nodes : t -> log:Log.t -> unit

(** [set_refs t ~refs] add to [t] all the refs from the tree log. *)
val set_refs : t -> refs:Refs.t -> unit

(** Same as [set_refs], but one ref at a time. *)
val set_ref : t -> rev:Rev.t -> ref_kind:Ref_kind.t -> unit

(** {1 Nodes} *)

module Node : sig
  (** The node itself doesn't carry much information, rather it is simply a
      pointer to a location in the tree. Thus the functions operating on nodes
      typically also require to be supplied the tree.

      For convenience to users writing algorithms on git trees, the type [t]
      exposes an efficient comparable interface, meaning you can e.g. manipulate
      containers indexed by nodes.

      An invariant that holds in the structure and on which you can rely is that
      the parents of a node are always inserted in the tree before the node
      itself (from left to right), and thus if [n1 > n2] (using the node
      comparison function) then you can be certain that [n1] is not a parent of
      [n2]. *)

  type t [@@deriving compare, equal, hash, sexp_of]

  include Comparable.S with type t := t
end

module Node_kind : sig
  type t = private
    | Root of { rev : Rev.t }
    | Commit of
        { rev : Rev.t
        ; parent : Node.t
        }
    | Merge of
        { rev : Rev.t
        ; parent1 : Node.t
        ; parent2 : Node.t
        }
  [@@deriving equal, sexp_of]

  (** A helper to access the revision of the node itself. This simply returns
      the first argument of each constructor. *)
  val rev : t -> Rev.t
end

(** Access the revision of a node. *)
val rev : t -> Node.t -> Rev.t

(** Return 0 parents for root nodes, 1 parent for commits, and 2 parents for
    merge nodes. *)
val parents : t -> Node.t -> Node.t list

(** [prepend_parents tree node nodes] is an equivalent but more efficient
    version of [parents tree node @ nodes]. It may be useful for recursive
    traversal algorithms. *)
val prepend_parents : t -> Node.t -> Node.t list -> Node.t list

(** Access the given node from the tree and return its node kind. *)
val node_kind : t -> Node.t -> Node_kind.t

(** If the tree has refs (such as tags or branches) attached to this node,
    they will all be returned by [refs tree node]. The order of the refs in
    the resulting list is not specified. *)
val node_refs : t -> Node.t -> Ref_kind.t list

module Descendance : sig
  (** Descendance is a relation between 2 nodes of the tree. Matching on it is
      useful for example when considering the status of a branch head with
      respect to its upstream counterpart. *)
  type t =
    | Same_node
    | Strict_ancestor
    | Strict_descendant
    | Other
  [@@deriving equal, enumerate, hash, sexp_of]
end

val descendance : t -> Node.t -> Node.t -> Descendance.t

(** Return the number of nodes the tree currently holds. *)
val node_count : t -> int

(** {1 Refs} *)

(** List known refs. *)
val refs : t -> Refs.t

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

(** [greatest_common_ancestors t nodes] returns the list of nodes that are the
    greatest common ancestors of the nodes in the list [nodes] in the tree [t].

    A greatest common ancestor of a set of nodes is a node that is an ancestor
    of all the nodes in the set and is not a strict ancestor of any other common
    ancestor of the nodes.

    If the nodes in [nodes] are unrelated, the function returns an empty list. If
    there are multiple greatest common ancestors, all of them are included in
    the returned list.

    Multiple nodes may have multiple greatest common ancestors, especially in
    cases of complex merge histories, hence the list return type. *)
val greatest_common_ancestors : t -> Node.t list -> Node.t list

(** {1 Log} *)

(** Rebuild the log line that represented this node in the git log. This is
    mainly used for tests and display purposes. *)
val log_line : t -> Node.t -> Log.Line.t

(** Rebuild the entire log. *)
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
