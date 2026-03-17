(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let () =
  Cmdlang_cmdliner_err_runner.run
    Volgo_vcs_cli.main
    ~name:"volgo-vcs"
    ~version:"%%VERSION%%"
;;
