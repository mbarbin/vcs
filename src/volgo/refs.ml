(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

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
