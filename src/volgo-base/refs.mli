(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

module Line : sig
  type t = Vcs.Refs.Line.t =
    { rev : Rev.t
    ; ref_kind : Ref_kind.t
    }

  include module type of Vcs.Refs.Line with type t := t
end

type t = Line.t list

include module type of Vcs.Refs with type t := t and module Line := Vcs.Refs.Line

val tags : t -> Set.M(Tag_name).t
val local_branches : t -> Set.M(Branch_name).t
val remote_branches : t -> Set.M(Remote_branch_name).t

(** To lookup the revision of references (branch, tag, etc.), it is usually
    quite cheap to get all refs using {!val:Vcs.refs}, turn the result into a
    map with this function, and use the map for the lookups rather than trying
    to run one git command per lookup. You may also use
    {!val:Vcs.Graph.find_ref} if you build the complete graph with
    {!val:Vcs.graph}. *)
val to_map : t -> Rev.t Map.M(Ref_kind).t
