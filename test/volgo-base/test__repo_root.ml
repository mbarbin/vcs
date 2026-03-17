(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let values = [ Vcs.Repo_root.v "/tmp/foo"; Vcs.Repo_root.v "/home/user/dev/repo" ]

let%expect_test "hash" =
  Hash_test.run (module Vcs.Repo_root) (module Volgo_base.Vcs.Repo_root) values;
  [%expect
    {|
    ({ value = "/tmp/foo" },
     { stdlib_hash = 300202224; vcs_hash = 300202224; vcs_base_hash = 300202224 })
    ({ value = "/tmp/foo"; seed = 0 },
     { stdlib_hash = 300202224; vcs_hash = 300202224; vcs_base_hash = 300202224 })
    ({ value = "/tmp/foo"; seed = 42 },
     { stdlib_hash = 202387283; vcs_hash = 202387283; vcs_base_hash = 202387283 })
    ({ value = "/home/user/dev/repo" },
     { stdlib_hash = 793408912; vcs_hash = 793408912; vcs_base_hash = 793408912 })
    ({ value = "/home/user/dev/repo"; seed = 0 },
     { stdlib_hash = 793408912; vcs_hash = 793408912; vcs_base_hash = 793408912 })
    ({ value = "/home/user/dev/repo"; seed = 42 },
     { stdlib_hash = 628866208; vcs_hash = 628866208; vcs_base_hash = 628866208 })
    |}];
  ()
;;
