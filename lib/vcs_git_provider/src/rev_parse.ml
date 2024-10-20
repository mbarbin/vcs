(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
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

open! Import

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  let current_branch t ~repo_root =
    Runtime.git
      t
      ~cwd:(repo_root |> Vcs.Repo_root.to_absolute_path)
      ~args:[ "rev-parse"; "--abbrev-ref"; "HEAD" ]
      ~f:(fun output ->
        let%bind stdout = Vcs.Git.Or_error.exit0_and_stdout output in
        match Vcs.Branch_name.of_string (String.strip stdout) with
        | Ok _ as ok -> ok
        | Error (`Msg m) -> Or_error.error_string m [@coverage off])
  ;;

  let current_revision t ~repo_root =
    Runtime.git
      t
      ~cwd:(repo_root |> Vcs.Repo_root.to_absolute_path)
      ~args:[ "rev-parse"; "--verify"; "HEAD^{commit}" ]
      ~f:(fun output ->
        let%bind stdout = Vcs.Git.Or_error.exit0_and_stdout output in
        match Vcs.Rev.of_string (String.strip stdout) with
        | Ok _ as ok -> ok
        | Error (`Msg m) -> Or_error.error_string m [@coverage off])
  ;;
end
