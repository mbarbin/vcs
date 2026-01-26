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
    | Root of { rev : Rev.t }
    | Commit of
        { rev : Rev.t
        ; parent : Rev.t
        }
    | Merge of
        { rev : Rev.t
        ; parent1 : Rev.t
        ; parent2 : Rev.t
        }

  let to_dyn = function
    | Root { rev } -> Dyn.inline_record "Root" [ "rev", Rev.to_dyn rev ]
    | Commit { rev; parent } ->
      Dyn.inline_record "Commit" [ "rev", Rev.to_dyn rev; "parent", Rev.to_dyn parent ]
    | Merge { rev; parent1; parent2 } ->
      Dyn.inline_record
        "Merge"
        [ "rev", Rev.to_dyn rev
        ; "parent1", Rev.to_dyn parent1
        ; "parent2", Rev.to_dyn parent2
        ]
  ;;

  let sexp_of_t t = Dyn.to_sexp (to_dyn t)

  let equal a b =
    phys_equal a b
    ||
    match a, b with
    | Root a, Root { rev } -> Rev.equal a.rev rev
    | Commit a, Commit { rev; parent } -> Rev.equal a.rev rev && Rev.equal a.parent parent
    | Merge a, Merge { rev; parent1; parent2 } ->
      Rev.equal a.rev rev && Rev.equal a.parent1 parent1 && Rev.equal a.parent2 parent2
    | (Root _ | Commit _ | Merge _), _ -> false
  ;;

  let rev = function
    | Commit { rev; _ } | Merge { rev; _ } | Root { rev } -> rev
  ;;

  let parents = function
    | Root { rev = _ } -> []
    | Commit { rev = _; parent } -> [ parent ]
    | Merge { rev = _; parent1; parent2 } -> [ parent1; parent2 ]
  ;;

  let parent_count = function
    | Root { rev = _ } -> 0
    | Commit { rev = _; parent = _ } -> 1
    | Merge { rev = _; parent1 = _; parent2 = _ } -> 2
  ;;

  let create ~rev ~parents =
    match parents with
    | [] -> Root { rev }
    | [ parent ] -> Commit { rev; parent }
    | [ parent1; parent2 ] -> Merge { rev; parent1; parent2 }
    | _ -> Err.raise [ Pp.text "Too many parents (expected 0, 1, or 2)." ]
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

let roots (t : t) =
  List.filter_map t ~f:(fun line ->
    match (line : Line.t) with
    | Root { rev } -> Some rev
    | Commit _ | Merge _ -> None)
;;
