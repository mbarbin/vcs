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

  let equal =
    (fun a__001_ b__002_ ->
       if a__001_ == b__002_
       then true
       else (
         match a__001_, b__002_ with
         | Root _a__003_, Root _b__004_ -> Rev.equal _a__003_.rev _b__004_.rev
         | Root _, _ -> false
         | _, Root _ -> false
         | Commit _a__005_, Commit _b__006_ ->
           Rev.equal _a__005_.rev _b__006_.rev
           && Rev.equal _a__005_.parent _b__006_.parent
         | Commit _, _ -> false
         | _, Commit _ -> false
         | Merge _a__007_, Merge _b__008_ ->
           Rev.equal _a__007_.rev _b__008_.rev
           && Rev.equal _a__007_.parent1 _b__008_.parent1
           && Rev.equal _a__007_.parent2 _b__008_.parent2)
     : t -> t -> bool)
  ;;

  let rev = function
    | Commit { rev; _ } | Merge { rev; _ } | Root { rev } -> rev
  ;;
end

module T = struct
  [@@@coverage off]

  type t = Line.t list

  let to_dyn t = Dyn.list Line.to_dyn t
  let sexp_of_t t = sexp_of_list Line.sexp_of_t t
  let equal a b = equal_list Line.equal a b
end

include T

let roots (t : t) =
  List.filter_map t ~f:(fun line ->
    match (line : Line.t) with
    | Root { rev } -> Some rev
    | Commit _ | Merge _ -> None)
;;
