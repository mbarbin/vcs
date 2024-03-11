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
  type t =
    { remote_name : Remote_name.t
    ; branch_name : Branch_name.t
    }
  [@@deriving compare, equal, hash, sexp_of]
end

include T
include Comparable.Make (T)

let to_string { remote_name; branch_name } =
  Printf.sprintf
    "%s/%s"
    (Remote_name.to_string remote_name)
    (Branch_name.to_string branch_name)
;;

let of_string str =
  match String.lsplit2 str ~on:'/' with
  | None ->
    Or_error.error_s [%sexp "Remote_branch_name.of_string: invalid entry", (str : string)]
  | Some (remote, branch) ->
    let%bind remote_name = Remote_name.of_string remote in
    let%map branch_name = Branch_name.of_string branch in
    { remote_name; branch_name }
;;

let v t = t |> of_string |> Or_error.ok_exn
