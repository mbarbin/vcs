(*_******************************************************************************)
(*_  Vcs - a Versatile OCaml Library for Git Operations                         *)
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

module Change : sig
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

  include module type of Vcs.Name_status.Change with type t := t
end

module Changed : sig
  type t = Vcs.Name_status.Changed.t =
    | Between of
        { src : Rev.t
        ; dst : Rev.t
        }

  include module type of Vcs.Name_status.Changed with type t := t
end

type t = Change.t list

include
  module type of Vcs.Name_status
  with type t := t
   and module Change := Vcs.Name_status.Change
   and module Changed := Vcs.Name_status.Changed

val files : t -> Set.M(Path_in_repo).t
val files_at_src : t -> Set.M(Path_in_repo).t
val files_at_dst : t -> Set.M(Path_in_repo).t
