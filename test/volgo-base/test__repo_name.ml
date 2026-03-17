(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let values = [ Vcs.Repo_name.v "vcs"; Vcs.Repo_name.v "loc" ]

let%expect_test "hash" =
  Hash_test.run (module Vcs.Repo_name) (module Volgo_base.Vcs.Repo_name) values;
  [%expect
    {|
    ({ value = "vcs" },
     { stdlib_hash = 416069169; vcs_hash = 416069169; vcs_base_hash = 416069169 })
    ({ value = "vcs"; seed = 0 },
     { stdlib_hash = 416069169; vcs_hash = 416069169; vcs_base_hash = 416069169 })
    ({ value = "vcs"; seed = 42 },
     { stdlib_hash = 363610390; vcs_hash = 363610390; vcs_base_hash = 363610390 })
    ({ value = "loc" },
     { stdlib_hash = 41095261; vcs_hash = 41095261; vcs_base_hash = 41095261 })
    ({ value = "loc"; seed = 0 },
     { stdlib_hash = 41095261; vcs_hash = 41095261; vcs_base_hash = 41095261 })
    ({ value = "loc"; seed = 42 },
     { stdlib_hash = 683447793; vcs_hash = 683447793; vcs_base_hash = 683447793 })
    |}];
  ()
;;
