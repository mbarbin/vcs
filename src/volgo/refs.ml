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

module Line = struct
  [@@@coverage off]

  type t =
    { rev : Rev.t
    ; ref_kind : Ref_kind.t
    }

  let to_dyn { rev; ref_kind } =
    Dyn.record [ "rev", Rev.to_dyn rev; "ref_kind", Ref_kind.to_dyn ref_kind ]
  ;;

  let sexp_of_t t = Dyn.to_sexp (to_dyn t)

  let equal t ({ rev; ref_kind } as t2) =
    phys_equal t t2 || (Rev.equal t.rev rev && Ref_kind.equal t.ref_kind ref_kind)
  ;;
end

module T = struct
  [@@@coverage off]

  type t = Line.t list

  let to_dyn t = Dyn.list Line.to_dyn t
  let sexp_of_t t = sexp_of_list Line.sexp_of_t t
  let equal a b = List.equal a b ~eq:Line.equal
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
