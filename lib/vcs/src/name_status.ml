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

open! Import

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
  [@@deriving sexp_of]

  let equal =
    (fun a__001_ b__002_ ->
       if Stdlib.( == ) a__001_ b__002_
       then true
       else (
         match a__001_, b__002_ with
         | Added _a__003_, Added _b__004_ -> Path_in_repo.equal _a__003_ _b__004_
         | Added _, _ -> false
         | _, Added _ -> false
         | Removed _a__005_, Removed _b__006_ -> Path_in_repo.equal _a__005_ _b__006_
         | Removed _, _ -> false
         | _, Removed _ -> false
         | Modified _a__007_, Modified _b__008_ -> Path_in_repo.equal _a__007_ _b__008_
         | Modified _, _ -> false
         | _, Modified _ -> false
         | Copied _a__009_, Copied _b__010_ ->
           Stdlib.( && )
             (Path_in_repo.equal _a__009_.src _b__010_.src)
             (Stdlib.( && )
                (Path_in_repo.equal _a__009_.dst _b__010_.dst)
                (equal_int _a__009_.similarity _b__010_.similarity))
         | Copied _, _ -> false
         | _, Copied _ -> false
         | Renamed _a__011_, Renamed _b__012_ ->
           Stdlib.( && )
             (Path_in_repo.equal _a__011_.src _b__012_.src)
             (Stdlib.( && )
                (Path_in_repo.equal _a__011_.dst _b__012_.dst)
                (equal_int _a__011_.similarity _b__012_.similarity)))
     : t -> t -> bool)
  ;;
end

module T = struct
  type t = Change.t list [@@deriving sexp_of]
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
  [@@deriving sexp_of]

  let equal =
    (fun a__034_ b__035_ ->
       if Stdlib.( == ) a__034_ b__035_
       then true
       else (
         match a__034_, b__035_ with
         | Between _a__036_, Between _b__037_ ->
           Stdlib.( && )
             (Rev.equal _a__036_.src _b__037_.src)
             (Rev.equal _a__036_.dst _b__037_.dst))
     : t -> t -> bool)
  ;;
end
