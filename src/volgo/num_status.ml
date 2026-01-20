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

module Key = struct
  [@@@coverage off]

  type t =
    | One_file of Path_in_repo.t
    | Two_files of
        { src : Path_in_repo.t
        ; dst : Path_in_repo.t
        }

  let to_dyn = function
    | One_file path -> Dyn.Variant ("One_file", [ Path_in_repo.to_dyn path ])
    | Two_files { src; dst } ->
      Dyn.inline_record
        "Two_files"
        [ "src", Path_in_repo.to_dyn src; "dst", Path_in_repo.to_dyn dst ]
  ;;

  let sexp_of_t t = Dyn.to_sexp (to_dyn t)

  let compare a b =
    if phys_equal a b
    then 0
    else (
      match a, b with
      | One_file a, One_file b -> Path_in_repo.compare a b
      | One_file _, _ -> -1
      | _, One_file _ -> 1
      | Two_files a, Two_files { src; dst } ->
        (match Path_in_repo.compare a.src src with
         | 0 -> Path_in_repo.compare a.dst dst
         | n -> n))
  ;;

  let equal a b = compare a b = 0
  let seeded_hash = (Hashtbl.seeded_hash : int -> t -> int)
  let hash = (Hashtbl.hash : t -> int)
end

module Change = struct
  [@@@coverage off]

  module Num_stat = struct
    type t =
      | Num_lines_in_diff of Num_lines_in_diff.t
      | Binary_file

    let to_dyn = function
      | Num_lines_in_diff n ->
        Dyn.Variant ("Num_lines_in_diff", [ Num_lines_in_diff.to_dyn n ])
      | Binary_file -> Dyn.Variant ("Binary_file", [])
    ;;

    let sexp_of_t t = Dyn.to_sexp (to_dyn t)

    let equal a b =
      phys_equal a b
      ||
      match a, b with
      | Num_lines_in_diff a, Num_lines_in_diff b -> Num_lines_in_diff.equal a b
      | Binary_file, Binary_file -> true
      | (Num_lines_in_diff _ | Binary_file), _ -> false
    ;;
  end

  type t =
    { key : Key.t
    ; num_stat : Num_stat.t
    }

  let to_dyn { key; num_stat } =
    Dyn.Record [ "key", key |> Key.to_dyn; "num_stat", num_stat |> Num_stat.to_dyn ]
  ;;

  let sexp_of_t t = Dyn.to_sexp (to_dyn t)

  let equal t ({ key; num_stat } as t2) =
    phys_equal t t2 || (Key.equal t.key key && Num_stat.equal t.num_stat num_stat)
  ;;
end

module T = struct
  type t = Change.t list

  let to_dyn t = Dyn.list Change.to_dyn t
  let sexp_of_t t : Sexplib0.Sexp.t = sexp_of_list Change.sexp_of_t t
end

include T

module Changed = struct
  [@@@coverage off]

  type t = Name_status.Changed.t =
    | Between of
        { src : Rev.t
        ; dst : Rev.t
        }

  let to_dyn = function
    | Between { src; dst } ->
      Dyn.inline_record "Between" [ "src", src |> Rev.to_dyn; "dst", dst |> Rev.to_dyn ]
  ;;

  let sexp_of_t t = Dyn.to_sexp (to_dyn t)

  let equal a b =
    phys_equal a b
    ||
    match a, b with
    | Between a, Between { src; dst } -> Rev.equal a.src src && Rev.equal a.dst dst
  ;;
end
