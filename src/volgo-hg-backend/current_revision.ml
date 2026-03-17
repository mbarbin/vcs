(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  let current_revision t ~repo_root =
    Runtime.hg
      t
      ~cwd:(repo_root |> Vcs.Repo_root.to_absolute_path)
      ~args:[ "log"; "-r"; "."; "--template"; "{node}" ]
      ~f:(fun output ->
        let open Result.Syntax in
        let* stdout = Vcs.Hg.Result.exit0_and_stdout output in
        match Vcs.Rev.of_string (String.strip stdout) with
        | Ok _ as ok -> ok
        | Error (`Msg m) -> Error (Err.create [ Pp.text m ]) [@coverage off])
  ;;
end
