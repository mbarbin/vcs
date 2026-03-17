(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  let rename_current_branch t ~repo_root ~to_ =
    Runtime.git
      t
      ~cwd:(repo_root |> Vcs.Repo_root.to_absolute_path)
      ~args:[ "branch"; "--move"; to_ |> Vcs.Branch_name.to_string ]
      ~f:Vcs.Git.Result.exit0
  ;;
end
