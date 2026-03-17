(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

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
        let open Result.Syntax in
        let* stdout = Vcs.Hg.Result.exit0_and_stdout output in
        Vcs.Private.try_with (fun () ->
          String.split_lines stdout |> List.map ~f:Vcs.Path_in_repo.v))
  ;;
end
