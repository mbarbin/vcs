(*******************************************************************************)
(*  Vcs - a versatile OCaml library for Git interaction                        *)
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

module Change = struct
  type t =
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
  [@@deriving sexp_of]
end

type t = Change.t list [@@deriving sexp_of]

let files_at_src (t : t) =
  List.fold
    t
    ~init:(Set.empty (module Path_in_repo))
    ~f:(fun set change ->
      match change with
      | Added _ -> set
      | Removed path
      | Modified path
      | Copied { src = path; dst = _; similarity = _ }
      | Renamed { src = path; dst = _; similarity = _ } -> Set.add set path)
;;

let files_at_dst (t : t) =
  List.fold
    t
    ~init:(Set.empty (module Path_in_repo))
    ~f:(fun set change ->
      match change with
      | Removed _ -> set
      | Added path
      | Modified path
      | Copied { src = _; dst = path; similarity = _ }
      | Renamed { src = _; dst = path; similarity = _ } -> Set.add set path)
;;

let files (t : t) =
  List.fold
    t
    ~init:(Set.empty (module Path_in_repo))
    ~f:(fun set change ->
      match change with
      | Removed path | Added path | Modified path -> Set.add set path
      | Copied { src; dst; similarity = _ } | Renamed { src; dst; similarity = _ } ->
        Set.add (Set.add set src) dst)
;;

module Changed = struct
  type t =
    | Between of
        { src : Rev.t
        ; dst : Rev.t
        }
end
