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

let interpret_output { Vcs.Git.Output.exit_code; stdout; stderr = _ } =
  match exit_code with
  | 0 -> Ok (`Present (Vcs.File_contents.create stdout))
  | 128 -> Ok `Absent
  | _ -> Or_error.error_string "expected error code 0 or 128"
;;

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  let show_file_at_rev t ~repo_root ~rev ~path =
    Runtime.git
      t
      ~cwd:(repo_root |> Vcs.Repo_root.to_absolute_path)
      ~args:
        [ "show"
        ; Printf.sprintf
            "%s:%s"
            (rev |> Vcs.Rev.to_string)
            (path |> Vcs.Path_in_repo.to_string)
        ]
      ~f:interpret_output
  ;;
end
