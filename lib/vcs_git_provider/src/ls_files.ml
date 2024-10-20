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

  let ls_files t ~repo_root ~below =
    Runtime.git
      t
      ~cwd:(Vcs.Repo_root.append repo_root below)
      ~args:[ "ls-files"; "--full-name" ]
      ~f:(fun output ->
        let%bind stdout = Vcs.Git.Or_error.exit0_and_stdout output in
        Or_error.try_with (fun () ->
          String.split_lines stdout |> List.map ~f:Vcs.Path_in_repo.v))
  ;;
end
