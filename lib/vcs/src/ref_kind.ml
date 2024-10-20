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

open! Import

[@@@coverage off]

type t =
  | Local_branch of { branch_name : Branch_name.t }
  | Remote_branch of { remote_branch_name : Remote_branch_name.t }
  | Tag of { tag_name : Tag_name.t }
  | Other of { name : string }
[@@deriving sexp_of]

let compare =
  (fun a__001_ b__002_ ->
     if Stdlib.( == ) a__001_ b__002_
     then 0
     else (
       match a__001_, b__002_ with
       | Local_branch _a__003_, Local_branch _b__004_ ->
         Branch_name.compare _a__003_.branch_name _b__004_.branch_name
       | Local_branch _, _ -> -1
       | _, Local_branch _ -> 1
       | Remote_branch _a__005_, Remote_branch _b__006_ ->
         Remote_branch_name.compare
           _a__005_.remote_branch_name
           _b__006_.remote_branch_name
       | Remote_branch _, _ -> -1
       | _, Remote_branch _ -> 1
       | Tag _a__007_, Tag _b__008_ ->
         Tag_name.compare _a__007_.tag_name _b__008_.tag_name
       | Tag _, _ -> -1
       | _, Tag _ -> 1
       | Other _a__009_, Other _b__010_ -> compare_string _a__009_.name _b__010_.name)
   : t -> t -> int)
;;

let equal =
  (fun a__011_ b__012_ ->
     if Stdlib.( == ) a__011_ b__012_
     then true
     else (
       match a__011_, b__012_ with
       | Local_branch _a__013_, Local_branch _b__014_ ->
         Branch_name.equal _a__013_.branch_name _b__014_.branch_name
       | Local_branch _, _ -> false
       | _, Local_branch _ -> false
       | Remote_branch _a__015_, Remote_branch _b__016_ ->
         Remote_branch_name.equal _a__015_.remote_branch_name _b__016_.remote_branch_name
       | Remote_branch _, _ -> false
       | _, Remote_branch _ -> false
       | Tag _a__017_, Tag _b__018_ -> Tag_name.equal _a__017_.tag_name _b__018_.tag_name
       | Tag _, _ -> false
       | _, Tag _ -> false
       | Other _a__019_, Other _b__020_ -> equal_string _a__019_.name _b__020_.name)
   : t -> t -> bool)
;;

let seeded_hash = (Stdlib.Hashtbl.seeded_hash : int -> t -> int)
let hash = (Stdlib.Hashtbl.hash : t -> int)

let to_string = function
  | Local_branch { branch_name } -> "refs/heads/" ^ Branch_name.to_string branch_name
  | Remote_branch { remote_branch_name } ->
    "refs/remotes/" ^ Remote_branch_name.to_string remote_branch_name
  | Tag { tag_name } -> "refs/tags/" ^ Tag_name.to_string tag_name
  | Other { name } -> "refs/" ^ name
;;
