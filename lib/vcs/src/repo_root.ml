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

type t = Absolute_path.t [@@deriving compare, equal, hash, sexp_of]

let of_absolute_path t = t
let to_absolute_path t = t
let to_string t = t |> to_absolute_path |> Absolute_path.to_string
let of_string str = str |> Absolute_path.of_string >>| of_absolute_path
let v str = str |> of_string |> Or_error.ok_exn

let relativize t absolute_path =
  Absolute_path.chop_prefix ~prefix:(to_absolute_path t) absolute_path
  >>| Path_in_repo.of_relative_path
;;

let append t path_in_repo =
  Absolute_path.append t (Path_in_repo.to_relative_path path_in_repo)
;;
