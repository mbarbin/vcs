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

module T = struct
  [@@@coverage off]

  type t =
    | Local_branch of { branch_name : Branch_name.t }
    | Remote_branch of { remote_branch_name : Remote_branch_name.t }
    | Tag of { tag_name : Tag_name.t }
    | Other of { name : string }
  [@@deriving compare, equal, hash, sexp_of]
end

include T
include Comparable.Make (T)

let to_string = function
  | Local_branch { branch_name } -> "refs/heads/" ^ Branch_name.to_string branch_name
  | Remote_branch { remote_branch_name } ->
    "refs/remotes/" ^ Remote_branch_name.to_string remote_branch_name
  | Tag { tag_name } -> "refs/tags/" ^ Tag_name.to_string tag_name
  | Other { name } -> "refs/" ^ name
;;
