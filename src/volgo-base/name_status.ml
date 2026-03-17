(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

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
