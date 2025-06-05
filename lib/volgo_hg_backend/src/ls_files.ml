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

open! Import

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  let ls_files t ~repo_root ~below =
    Runtime.hg
      t
      ~cwd:(repo_root |> Vcs.Repo_root.to_absolute_path)
      ~args:
        (List.concat
           [ [ "files" ]
           ; (if Vcs.Path_in_repo.equal below Vcs.Path_in_repo.root
              then []
              else
                [ "--include"; Printf.sprintf "./%s/" (Vcs.Path_in_repo.to_string below) ])
           ])
      ~f:(fun output ->
        let open Result.Monad_syntax in
        let* stdout = Vcs.Hg.Result.exit0_and_stdout output in
        Vcs.Private.try_with (fun () ->
          String.split_lines stdout |> List.map ~f:Vcs.Path_in_repo.v))
  ;;
end
