(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  let ls_files t ~repo_root ~below =
    Runtime.git
      t
      ~cwd:(Vcs.Repo_root.append repo_root below)
      ~args:[ "ls-files"; "--full-name" ]
      ~f:(fun output ->
        let open Result.Syntax in
        let* stdout = Vcs.Git.Result.exit0_and_stdout output in
        Vcs.Private.try_with (fun () ->
          String.split_lines stdout |> List.map ~f:Vcs.Path_in_repo.v))
  ;;
end
