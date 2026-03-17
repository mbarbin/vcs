(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  let add t ~repo_root ~path =
    Runtime.hg
      t
      ~cwd:(repo_root |> Vcs.Repo_root.to_absolute_path)
      ~args:[ "add"; path |> Vcs.Path_in_repo.to_string ]
      ~f:Vcs.Hg.Result.exit0
  ;;
end
