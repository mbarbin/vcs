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

module Line = struct
  [@@@coverage off]

  type t =
    { rev : Rev.t
    ; ref_kind : Ref_kind.t
    }
  [@@deriving equal, sexp_of]
end

module T = struct
  [@@@coverage off]

  type t = Line.t list [@@deriving equal, sexp_of]
end

include T

let tags (t : t) =
  List.filter_map t ~f:(function
    | { rev = _; ref_kind = Tag { tag_name } } -> Some tag_name
    | _ -> None)
  |> Set.of_list (module Tag_name)
;;

let local_branches (t : t) =
  List.filter_map t ~f:(function
    | { rev = _; ref_kind = Local_branch { branch_name } } -> Some branch_name
    | _ -> None)
;;

let remote_branches (t : t) =
  List.filter_map t ~f:(function
    | { rev = _; ref_kind = Remote_branch { remote_branch_name } } ->
      Some remote_branch_name
    | _ -> None)
;;

let to_map (t : t) =
  List.fold
    t
    ~init:(Map.empty (module Ref_kind))
    ~f:(fun acc { rev; ref_kind } -> Map.add_exn acc ~key:ref_kind ~data:rev)
;;
