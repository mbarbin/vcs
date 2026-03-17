(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

[@@@coverage off]

type t =
  | Local_branch of { branch_name : Branch_name.t }
  | Remote_branch of { remote_branch_name : Remote_branch_name.t }
  | Tag of { tag_name : Tag_name.t }
  | Other of { name : string }

let to_dyn = function
  | Local_branch { branch_name } ->
    Dyn.inline_record "Local_branch" [ "branch_name", Branch_name.to_dyn branch_name ]
  | Remote_branch { remote_branch_name } ->
    Dyn.inline_record
      "Remote_branch"
      [ "remote_branch_name", Remote_branch_name.to_dyn remote_branch_name ]
  | Tag { tag_name } -> Dyn.inline_record "Tag" [ "tag_name", Tag_name.to_dyn tag_name ]
  | Other { name } -> Dyn.inline_record "Other" [ "name", Dyn.string name ]
;;

let sexp_of_t t = Dyn.to_sexp (to_dyn t)

let compare a b =
  if phys_equal a b
  then 0
  else (
    match a, b with
    | Local_branch a, Local_branch { branch_name } ->
      Branch_name.compare a.branch_name branch_name
    | Local_branch _, _ -> -1
    | _, Local_branch _ -> 1
    | Remote_branch a, Remote_branch { remote_branch_name } ->
      Remote_branch_name.compare a.remote_branch_name remote_branch_name
    | Remote_branch _, _ -> -1
    | _, Remote_branch _ -> 1
    | Tag a, Tag { tag_name } -> Tag_name.compare a.tag_name tag_name
    | Tag _, _ -> -1
    | _, Tag _ -> 1
    | Other a, Other { name } -> String.compare a.name name)
;;

let equal a b = compare a b = 0
let seeded_hash = (Hashtbl.seeded_hash : int -> t -> int)
let hash = (Hashtbl.hash : t -> int)

let to_string = function
  | Local_branch { branch_name } -> "refs/heads/" ^ Branch_name.to_string branch_name
  | Remote_branch { remote_branch_name } ->
    "refs/remotes/" ^ Remote_branch_name.to_string remote_branch_name
  | Tag { tag_name } -> "refs/tags/" ^ Tag_name.to_string tag_name
  | Other { name } -> "refs/" ^ name
;;
