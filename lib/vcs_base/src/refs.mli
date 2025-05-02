(*_******************************************************************************)
(*_  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*_  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
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
