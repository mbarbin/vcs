(*******************************************************************************)
(*  Volgo - a Versatile OCaml Library for Git Operations                       *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
(*                                                                             *)
(*  This file is part of Volgo.                                                *)
(*                                                                             *)
(*  Volgo is free software; you can redistribute it and/or modify it under     *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Volgo is distributed in the hope that it will be useful, but WITHOUT ANY   *)
(*  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*  the file `NOTICE.md` at the root of this repository for more details.      *)
(*                                                                             *)
(*  You should have received a copy of the GNU Lesser General Public License   *)
(*  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*******************************************************************************)

(* This module is partially derived from Iron (v0.9.114.44+47), file
 * [./hg/hg.ml], which is released under Apache 2.0:
 *
 * Copyright (c) 2016-2017 Jane Street Group, LLC <opensource-contacts@janestreet.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy
 * of the License at:
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 *
 * See the file `NOTICE.md` at the root of this repository for more details.
 *
 * Changes: This has similarities with the module [Hg.Status]. We added support
 * for renames, removed support for [Changed_by Rev.t], added [similarity] values
 * which are available in Git.
 *)

module Change = struct
  [@@@coverage off]

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

  let to_dyn = function
    | Added path -> Dyn.Variant ("Added", [ Path_in_repo.to_dyn path ])
    | Removed path -> Dyn.Variant ("Removed", [ Path_in_repo.to_dyn path ])
    | Modified path -> Dyn.Variant ("Modified", [ Path_in_repo.to_dyn path ])
    | Copied { src; dst; similarity } ->
      Dyn.inline_record
        "Copied"
        [ "src", Path_in_repo.to_dyn src
        ; "dst", Path_in_repo.to_dyn dst
        ; "similarity", Dyn.int similarity
        ]
    | Renamed { src; dst; similarity } ->
      Dyn.inline_record
        "Renamed"
        [ "src", Path_in_repo.to_dyn src
        ; "dst", Path_in_repo.to_dyn dst
        ; "similarity", Dyn.int similarity
        ]
  ;;

  let sexp_of_t t = Dyn.to_sexp (to_dyn t)

  let equal a b =
    phys_equal a b
    ||
    match a, b with
    | Added a, Added b -> Path_in_repo.equal a b
    | Removed a, Removed b -> Path_in_repo.equal a b
    | Modified a, Modified b -> Path_in_repo.equal a b
    | Copied a, Copied { src; dst; similarity } ->
      Path_in_repo.equal a.src src
      && Path_in_repo.equal a.dst dst
      && Int.equal a.similarity similarity
    | Renamed a, Renamed { src; dst; similarity } ->
      Path_in_repo.equal a.src src
      && Path_in_repo.equal a.dst dst
      && Int.equal a.similarity similarity
    | (Added _ | Removed _ | Modified _ | Copied _ | Renamed _), _ -> false
  ;;
end

module T = struct
  type t = Change.t list

  let sexp_of_t t = sexp_of_list Change.sexp_of_t t
end

include T

let files_at_src (t : t) =
  List.fold t ~init:[] ~f:(fun acc change ->
    match change with
    | Added _ -> acc
    | Removed path
    | Modified path
    | Copied { src = path; dst = _; similarity = _ }
    | Renamed { src = path; dst = _; similarity = _ } -> path :: acc)
  |> List.dedup_and_sort ~compare:Path_in_repo.compare
;;

let files_at_dst (t : t) =
  List.fold t ~init:[] ~f:(fun acc change ->
    match change with
    | Removed _ -> acc
    | Added path
    | Modified path
    | Copied { src = _; dst = path; similarity = _ }
    | Renamed { src = _; dst = path; similarity = _ } -> path :: acc)
  |> List.dedup_and_sort ~compare:Path_in_repo.compare
;;

let files (t : t) =
  List.fold t ~init:[] ~f:(fun acc change ->
    match change with
    | Removed path | Added path | Modified path -> path :: acc
    | Copied { src; dst; similarity = _ } | Renamed { src; dst; similarity = _ } ->
      src :: dst :: acc)
  |> List.dedup_and_sort ~compare:Path_in_repo.compare
;;

module Changed = struct
  [@@@coverage off]

  type t =
    | Between of
        { src : Rev.t
        ; dst : Rev.t
        }

  let to_dyn (Between { src; dst }) =
    Dyn.inline_record "Between" [ "src", Rev.to_dyn src; "dst", Rev.to_dyn dst ]
  ;;

  let sexp_of_t t = Dyn.to_sexp (to_dyn t)

  let equal a b =
    phys_equal a b
    ||
    match a, b with
    | Between a, Between { src; dst } -> Rev.equal a.src src && Rev.equal a.dst dst
  ;;
end
