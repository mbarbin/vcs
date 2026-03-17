(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  let current_branch t ~repo_root =
    Runtime.git
      t
      ~cwd:(repo_root |> Vcs.Repo_root.to_absolute_path)
      ~args:[ "rev-parse"; "--abbrev-ref"; "HEAD" ]
      ~f:(fun output ->
        let open Result.Syntax in
        let* stdout = Vcs.Git.Result.exit0_and_stdout output in
        let stdout = stdout |> String.strip in
        if String.equal stdout "HEAD"
        then Ok None
        else (
          match Vcs.Branch_name.of_string stdout with
          | Ok branch -> Ok (Some branch)
          | Error (`Msg m) -> Error (Err.create [ Pp.text m ]) [@coverage off]))
  ;;
end
