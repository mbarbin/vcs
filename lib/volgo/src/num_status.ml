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

open! Import

module Key = struct
  [@@@coverage off]

  type t =
    | One_file of Path_in_repo.t
    | Two_files of
        { src : Path_in_repo.t
        ; dst : Path_in_repo.t
        }
  [@@deriving sexp_of]

  let compare =
    (fun a__001_ b__002_ ->
       if a__001_ == b__002_
       then 0
       else (
         match a__001_, b__002_ with
         | One_file _a__003_, One_file _b__004_ -> Path_in_repo.compare _a__003_ _b__004_
         | One_file _, _ -> -1
         | _, One_file _ -> 1
         | Two_files _a__005_, Two_files _b__006_ ->
           (match Path_in_repo.compare _a__005_.src _b__006_.src with
            | 0 -> Path_in_repo.compare _a__005_.dst _b__006_.dst
            | n -> n))
     : t -> t -> int)
  ;;

  let equal =
    (fun a__007_ b__008_ ->
       if a__007_ == b__008_
       then true
       else (
         match a__007_, b__008_ with
         | One_file _a__009_, One_file _b__010_ -> Path_in_repo.equal _a__009_ _b__010_
         | One_file _, _ -> false
         | _, One_file _ -> false
         | Two_files _a__011_, Two_files _b__012_ ->
           Path_in_repo.equal _a__011_.src _b__012_.src
           && Path_in_repo.equal _a__011_.dst _b__012_.dst)
     : t -> t -> bool)
  ;;

  let seeded_hash = (Hashtbl.seeded_hash : int -> t -> int)
  let hash = (Hashtbl.hash : t -> int)
end

module Change = struct
  [@@@coverage off]

  module Num_stat = struct
    type t =
      | Num_lines_in_diff of Num_lines_in_diff.t
      | Binary_file
    [@@deriving sexp_of]

    let equal =
      (fun a__008_ b__009_ ->
         if a__008_ == b__009_
         then true
         else (
           match a__008_, b__009_ with
           | Num_lines_in_diff _a__010_, Num_lines_in_diff _b__011_ ->
             Num_lines_in_diff.equal _a__010_ _b__011_
           | Num_lines_in_diff _, _ -> false
           | _, Num_lines_in_diff _ -> false
           | Binary_file, Binary_file -> true)
       : t -> t -> bool)
    ;;
  end

  type t =
    { key : Key.t
    ; num_stat : Num_stat.t
    }
  [@@deriving sexp_of]

  let equal =
    (fun a__014_ b__015_ ->
       if a__014_ == b__015_
       then true
       else
         Key.equal a__014_.key b__015_.key
         && Num_stat.equal a__014_.num_stat b__015_.num_stat
     : t -> t -> bool)
  ;;
end

module T = struct
  type t = Change.t list [@@deriving sexp_of]
end

include T

module Changed = struct
  [@@@coverage off]

  type t = Name_status.Changed.t =
    | Between of
        { src : Rev.t
        ; dst : Rev.t
        }
  [@@deriving sexp_of]

  let equal =
    (fun a__022_ b__023_ ->
       if a__022_ == b__023_
       then true
       else (
         match a__022_, b__023_ with
         | Between _a__024_, Between _b__025_ ->
           Rev.equal _a__024_.src _b__025_.src && Rev.equal _a__024_.dst _b__025_.dst)
     : t -> t -> bool)
  ;;
end
