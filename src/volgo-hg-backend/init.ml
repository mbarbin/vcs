(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  let init t ~path =
    let open Result.Syntax in
    let* () = Runtime.hg t ~cwd:path ~args:[ "init" ] ~f:Vcs.Hg.Result.exit0 in
    Result.return (path |> Vcs.Repo_root.of_absolute_path)
  ;;
end
