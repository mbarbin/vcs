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

(** Building an in-memory representation of the commit graph of a git repository
    for queries related to the structure of its nodes and edges.

    This data structure only contains the nodes, as well as the location of
    known branches (local and remotes) and tags.

    The design is such that it is easy to add new nodes, and to compute the diff
    of what needs to be sent to a process holding such a value in memory to
    complete its view of a graph. *)

type t [@@deriving sexp_of]

(** Create an empty graph that has no nodes. *)
val create : unit -> t

(** {1 Initializing the graph}

    This part of the interface is the only part that mutates the graph. The graph
    manipulated in memory needs to know about the nodes and refs that are present in
    the git log.

    The calls to the functions [add_nodes] and [set_refs] are typically handled
    for you by the function [Vcs.graph], however they are exposed if you want to
    manually build graphs in more advanced ways (such as incrementally), or for
    testing purposes.

    Adding nodes or refs to a graph does not affect the git repository. These are
    simply operations that needs to be called to feed to [t] the information
    that already exists in the git log. *)

(** [add t ~log] add to [t] all the nodes from the log. This is idempotent -
    this doesn't add the nodes that [t] already knows. *)
val add_nodes : t -> log:Log.t -> unit

(** [set_refs t ~refs] add to [t] all the refs from the log. *)
val set_refs : t -> refs:Refs.t -> unit

(** Same as [set_refs], but one ref at a time. *)
val set_ref : t -> rev:Rev.t -> ref_kind:Ref_kind.t -> unit

(** {1 Nodes}

    A node doesn't carry much information, rather it is simply a pointer to a
    location in the graph. The functions operating on nodes typically require to
    be supplied the graph in order to access what the node is pointing to.

    For convenience to users writing algorithms on git graphs, the type [t]
    exposes an efficient comparable signature, meaning you can e.g. manipulate
    containers indexed by nodes (maps, sets, etc.).

    {2:ordering_invariant Ordering invariant}

    An invariant that holds in the structure and on which you can rely is that
    the parents of a node are always inserted in the graph before the node itself
    (from left to right), and thus if [n1 > n2] (using the node comparison
    function) then you can be certain that [n1] is not a parent of [n2]. *)

module Node : sig
  type t

  include Container_key.S with type t := t
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
  [@@deriving sexp_of]

  val equal : t -> t -> bool

  (** A helper to access the revision of the node itself. This simply returns
      the first argument of each constructor. *)
  val rev : t -> Rev.t
end

(** Access the revision of a node. *)
val rev : t -> node:Node.t -> Rev.t

(** Return 0 parents for root nodes, 1 parent for commits, and 2 parents for
    merge nodes. *)
val parents : t -> node:Node.t -> Node.t list

(** [prepend_parents graph ~node ~prepend_to:nodes] is an equivalent but more
    efficient version of [parents graph ~node @ nodes]. It may be useful for
    recursive traversal algorithms. *)
val prepend_parents : t -> node:Node.t -> prepend_to:Node.t list -> Node.t list

(** Access the given node from the graph and return its node kind. *)
val node_kind : t -> node:Node.t -> Node_kind.t

(** If the graph has refs (such as tags or branches) attached to this node, they
    will all be returned by [node_refs graph ~node]. The refs are returned
    ordered increasingly according to [Ref_kind.compare]. *)
val node_refs : t -> node:Node.t -> Ref_kind.t list

(** Return the number of nodes the graph currently holds. *)
val node_count : t -> int

(** {1 Refs} *)

(** List known refs, ordered increasingly according to [Ref_kind.compare]. *)
val refs : t -> Refs.t

(** Find a ref if it is present. *)
val find_ref : t -> ref_kind:Ref_kind.t -> Node.t option

(** {1 Revisions} *)

(** Find the node at the given revision if it exists in the graph. *)
val find_rev : t -> rev:Rev.t -> Node.t option

(** Tell if a graph contains a revision. [mem_rev graph ~rev = true] iif
    [find_rev graph ~rev = Some _]. *)
val mem_rev : t -> rev:Rev.t -> bool

(** {1 Roots & Leaves} *)

(** Return the list of nodes that do not have any parents. *)
val roots : t -> Node.t list

(** Return the list of nodes that do not have any children. *)
val leaves : t -> Node.t list

(** {1 Ancestors & Descendance}

    Given two nodes of the graph, we say that [a] is an ancestor of [d] iif
    there exists an oriented path that leads from [a] to [d]. We say that [a] is
    a strict ancestor of [d] if [a] is an ancestor of [d] and [a] is not equal
    to [d]. Symmetrically, if a node [a] is an ancestor of node [d], we also say that
    [d] is a descendant of [a]. *)

(** [is_strict_ancestor t ~ancestor:a ~descendant:b] returns [true] iif there
    exists a non empty path that leads from [a] to [b]. By definition, any node
    is not a strict ancestor of itself. .*)
val is_strict_ancestor : t -> ancestor:Node.t -> descendant:Node.t -> bool

(** [is_ancestor_or_equal t ~ancestor:a ~descendant:b] returns [true] iif there
    [a] is a strict ancestor of [b] or if [a] is equal to [b]. *)
val is_ancestor_or_equal : t -> ancestor:Node.t -> descendant:Node.t -> bool

(** [greatest_common_ancestors t ~nodes] returns the list of nodes that are the
    greatest common ancestors of the nodes in the list [nodes] in the graph [t].

    A greatest common ancestor of a set of nodes is a node that is an ancestor
    of all the nodes in the set and is not a strict ancestor of any other common
    ancestor of the nodes.

    If the nodes in [nodes] do not have common ancestors, the function returns
    an empty list. If there are multiple greatest common ancestors, all of them
    are included in the returned list.

    A set of nodes may have multiple greatest common ancestors, especially in
    cases of complex merge histories, hence the list returned type. *)
val greatest_common_ancestors : t -> nodes:Node.t list -> Node.t list

module Descendance : sig
  (** Given two nodes we can determine whether one is an ancestor of the other.
      We encode the four cases of the result into a variant type named
      [Descendance.t]. *)

  type t =
    | Same_node
    | Strict_ancestor
    | Strict_descendant
    | Other

  val all : t list

  include Container_key.S with type t := t
end

(** [descendance graph a b] characterizes the descendance relation between
    nodes [a] and [b]. For example, it returns [Strict_ancestor] if
    [is_strict_ancestor graph ~ancestor:a ~descendant:b] holds. Be mindful
    that the order of the arguments [a] and [b] matters.

    For example, consider the following commit graph, with history going from
    older commits at the bottom to newer commits at the top (like in "gitk"):

    {v
     |      |
     e      f
      \    /
       \  /
        \/
        a
        |
        | root
    v}

    - [descendance graph a a] returns [Same_node]
    - [descendance graph a f] returns [Strict_ancestor]
    - [descendance graph f a] returns [Strict_descendant]
    - [descendance graph e f] returns [Other] *)
val descendance : t -> Node.t -> Node.t -> Descendance.t

(** {1 Log} *)

(** Rebuild the log line that represented this node in the git log. This is
    mainly used for tests and display purposes. *)
val log_line : t -> node:Node.t -> Log.Line.t

(** Rebuild the entire log. *)
val log : t -> Log.t

(** {1 Subgraph}

    Given a commit graph, we call subgraph a subset of the graph that contains
    nodes that are connected to each other, excluding from the rest of the graph
    nodes that are not.

    Having multiple subgraphs may happen for example if the graph contains
    multiple branches that are isolated and do not share history (e.g. "main"
    and "gh-pages").

    The root nodes of two different subgraphs are necessary distinct, by
    definition. However, note that two distinct roots of a graph may in fact
    belong to the same subgraph, if two of their respective descendants were
    subsequently merged. *)

module Subgraph : sig
  type t =
    { log : Log.t
    ; refs : Refs.t
    }
  [@@deriving sexp_of]

  val is_empty : t -> bool
end

(** Partition the commit graph into the subgraphs it contains. By convention, if
    [empty] denotes an empty graph, [subgraphs empty] returns the empty list,
    rather than a list containing an empty subgraph. A generalization of this
    convention is that the subgraphs returned by [subgraphs] are never empty. *)
val subgraphs : t -> Subgraph.t list

(** Build a commit graph containing only the supplied subgraph. *)
val of_subgraph : Subgraph.t -> t

(** {1 Summary} *)

module Summary : sig
  type t [@@deriving sexp_of]
end

(** Print a summary for use in expect test and quick exploratory tests *)
val summary : t -> Summary.t

(** {1 Low level node ordering}

    This part of the interface is exposed for advanced usage only.

    We make no guarantee about the stability of node ordering across vcs
    versions. The order in which nodes are stored is not fully specified,
    outside of the ordering invariant discussed {{!ordering_invariant} here}.
    The specific ordering that result from one specific execution path is
    considered to be valid only for the lifetime of the graph.

    These helpers are exposed if you want to write algorithms working on graph
    that take advantage of operations working on integers, if the rest of the
    exposed API isn't enough for your use case. *)

val get_node_exn : t -> index:int -> Node.t
val node_index : Node.t -> int
