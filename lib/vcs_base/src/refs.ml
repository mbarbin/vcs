(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024 Mathieu Barbin <mathieu.barbin@gmail.com>               *)
(*                                                                             *)
(*  This file is part of Vcs.                                                  *)
(*                                                                             *)
(*  Vcs is free software; you can redistribute it and/or modify it under       *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Vcs is distributed in the hope that it will be useful, but WITHOUT ANY     *)
(*  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*  the file `NOTICE.md` at the root of this repository for more details.      *)
(*                                                                             *)
(*  You should have received a copy of the GNU Lesser General Public License   *)
(*  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*******************************************************************************)

module Line = struct
  type t = Vcs.Refs.Line.t =
    { rev : Rev.t
    ; ref_kind : Ref_kind.t
    }

  include (Vcs.Refs.Line : module type of Vcs.Refs.Line with type t := t)
end

type t = Line.t list

include (
  Vcs.Refs : module type of Vcs.Refs with type t := t and module Line := Vcs.Refs.Line)

let tags t = Set.of_list (module Tag_name) (Vcs.Refs.tags t)
let local_branches t = Set.of_list (module Branch_name) (Vcs.Refs.local_branches t)

let remote_branches t =
  Set.of_list (module Remote_branch_name) (Vcs.Refs.remote_branches t)
;;

let to_map (t : t) =
  List.fold
    t
    ~init:(Map.empty (module Ref_kind))
    ~f:(fun acc { rev; ref_kind } -> Map.add_exn acc ~key:ref_kind ~data:rev)
;;
