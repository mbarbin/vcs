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

module Line = struct
  [@@@coverage off]

  type t =
    { rev : Rev.t
    ; ref_kind : Ref_kind.t
    }
  [@@deriving sexp_of]

  let equal =
    (fun a__001_ b__002_ ->
       if a__001_ == b__002_
       then true
       else
         Rev.equal a__001_.rev b__002_.rev
         && Ref_kind.equal a__001_.ref_kind b__002_.ref_kind
     : t -> t -> bool)
  ;;
end

module T = struct
  [@@@coverage off]

  type t = Line.t list [@@deriving sexp_of]

  let equal a b = equal_list Line.equal a b
end

include T

let tags (t : t) =
  List.filter_map t ~f:(function
    | { Line.rev = _; ref_kind = Tag { tag_name } } -> Some tag_name
    | _ -> None)
  |> List.sort ~compare:Tag_name.compare
;;

let local_branches (t : t) =
  List.filter_map t ~f:(function
    | { Line.rev = _; ref_kind = Local_branch { branch_name } } -> Some branch_name
    | _ -> None)
  |> List.sort ~compare:Branch_name.compare
;;

let remote_branches (t : t) =
  List.filter_map t ~f:(function
    | { Line.rev = _; ref_kind = Remote_branch { remote_branch_name } } ->
      Some remote_branch_name
    | _ -> None)
  |> List.sort ~compare:Remote_branch_name.compare
;;
