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

type t = Vcs.Num_status.Key.t =
  | One_file of Vcs.Path_in_repo.t
  | Two_files of
      { src : Vcs.Path_in_repo.t
      ; dst : Vcs.Path_in_repo.t
      }
[@@deriving equal, sexp_of]

let arrow = lazy (String.Search_pattern.create " => ")

let parse_exn str =
  try
    match String.Search_pattern.split_on (force arrow) str with
    | [ str ] -> One_file (Vcs.Path_in_repo.v str)
    | [ left; right ] ->
      let prefix, left_of_arrow = String.rsplit2_exn left ~on:'{' in
      let right_of_arrow, suffix = String.lsplit2_exn right ~on:'}' in
      Two_files
        { src = Vcs.Path_in_repo.v (prefix ^ left_of_arrow ^ suffix)
        ; dst = Vcs.Path_in_repo.v (prefix ^ right_of_arrow ^ suffix)
        }
    | _ :: _ :: _ -> raise_s [%sexp "Too many '=>'"]
    | [] -> assert false
  with
  | exn ->
    raise_s
      [%sexp
        "Git_cli.Munged_path.parse_exn", "invalid path", (str : string), (exn : Exn.t)]
;;
