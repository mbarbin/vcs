(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let interpret_output (output : Vcs.Git.Output.t) =
  Vcs.Git.Result.exit_code output ~accept:[ 0, `Present; 128, `Absent ]
  |> Result.map ~f:(function
    | `Present -> `Present (Vcs.File_contents.create output.stdout)
    | `Absent -> `Absent)
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
