(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let values = [ Vcs.Author.v "John Doe"; Vcs.Author.v "Jane Doe" ]

let%expect_test "hash" =
  Hash_test.run (module Vcs.Author) (module Volgo_base.Vcs.Author) values;
  [%expect
    {|
    ({ value = "John Doe" },
     { stdlib_hash = 719227130; vcs_hash = 719227130; vcs_base_hash = 719227130 })
    ({ value = "John Doe"; seed = 0 },
     { stdlib_hash = 719227130; vcs_hash = 719227130; vcs_base_hash = 719227130 })
    ({ value = "John Doe"; seed = 42 },
     { stdlib_hash = 81441934; vcs_hash = 81441934; vcs_base_hash = 81441934 })
    ({ value = "Jane Doe" },
     { stdlib_hash = 659235483; vcs_hash = 659235483; vcs_base_hash = 659235483 })
    ({ value = "Jane Doe"; seed = 0 },
     { stdlib_hash = 659235483; vcs_hash = 659235483; vcs_base_hash = 659235483 })
    ({ value = "Jane Doe"; seed = 42 },
     { stdlib_hash = 443135183; vcs_hash = 443135183; vcs_base_hash = 443135183 })
    |}];
  ()
;;
