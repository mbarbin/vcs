(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module M = struct
  let executable_basename = "git"

  module Output = Vcs.Git.Output
end

include Make_runtime.Make (M)

let git = vcs_cli

module Private = struct
  let find_executable ~path =
    Make_runtime.Private.find_executable ~path ~executable_basename:M.executable_basename
  ;;
end
