(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

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
