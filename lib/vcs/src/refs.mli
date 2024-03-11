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

(** Capturing the information related to git refs.

    In this file we represent the output of the [git show-ref] command. In
    particular we represent the location of all known local branches heads,
    remote branches heads and tags.

    It is worth noting that the location of the remote branches is the state of
    the remote branches as they are currently known locally. To connect to the
    remote repository and retrieves information about the remote references, see
    [Fetch_remote]. *)

module Line : sig
  type t =
    { rev : Rev.t
    ; ref_kind : Ref_kind.t
    }
  [@@deriving equal, sexp_of]
end

type t = Line.t list [@@deriving equal, sexp_of]

(** {1 Accessors} *)

val tags : t -> Set.M(Tag_name).t
val local_branches : t -> Branch_name.t list
val remote_branches : t -> Remote_branch_name.t list
