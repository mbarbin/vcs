(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let values = [ Vcs.Branch_name.main; Vcs.Branch_name.v "my-branch" ]

let%expect_test "hash" =
  Hash_test.run (module Vcs.Branch_name) (module Volgo_base.Vcs.Branch_name) values;
  [%expect
    {|
    ({ value = "main" },
     { stdlib_hash = 763421968; vcs_hash = 763421968; vcs_base_hash = 763421968 })
    ({ value = "main"; seed = 0 },
     { stdlib_hash = 763421968; vcs_hash = 763421968; vcs_base_hash = 763421968 })
    ({ value = "main"; seed = 42 },
     { stdlib_hash = 1007953461
     ; vcs_hash = 1007953461
     ; vcs_base_hash = 1007953461
     })
    ({ value = "my-branch" },
     { stdlib_hash = 977970132; vcs_hash = 977970132; vcs_base_hash = 977970132 })
    ({ value = "my-branch"; seed = 0 },
     { stdlib_hash = 977970132; vcs_hash = 977970132; vcs_base_hash = 977970132 })
    ({ value = "my-branch"; seed = 42 },
     { stdlib_hash = 513500652; vcs_hash = 513500652; vcs_base_hash = 513500652 })
    |}];
  ()
;;
