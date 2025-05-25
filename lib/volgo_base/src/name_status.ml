(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
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

module Change = struct
  type t = Vcs.Name_status.Change.t =
    | Added of Path_in_repo.t
    | Removed of Path_in_repo.t
    | Modified of Path_in_repo.t
    | Copied of
        { src : Path_in_repo.t
        ; dst : Path_in_repo.t
        ; similarity : int
        }
    | Renamed of
        { src : Path_in_repo.t
        ; dst : Path_in_repo.t
        ; similarity : int
        }

  include (
    Vcs.Name_status.Change : module type of Vcs.Name_status.Change with type t := t)
end

module Changed = struct
  type t = Vcs.Name_status.Changed.t =
    | Between of
        { src : Rev.t
        ; dst : Rev.t
        }

  include (
    Vcs.Name_status.Changed : module type of Vcs.Name_status.Changed with type t := t)
end

type t = Change.t list

include (
  Vcs.Name_status :
    module type of Vcs.Name_status
    with type t := t
     and module Change := Vcs.Name_status.Change
     and module Changed := Vcs.Name_status.Changed)

let files t = Set.of_list (module Path_in_repo) (Vcs.Name_status.files t)
let files_at_src t = Set.of_list (module Path_in_repo) (Vcs.Name_status.files_at_src t)
let files_at_dst t = Set.of_list (module Path_in_repo) (Vcs.Name_status.files_at_dst t)
