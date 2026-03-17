(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module M = struct
  let executable_basename = "hg"

  module Output = Vcs.Hg.Output
end

include Volgo_git_unix.Make_runtime.Make (M)

let hg = vcs_cli
