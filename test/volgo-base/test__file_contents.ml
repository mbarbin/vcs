(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let values = [ Vcs.File_contents.create ""; Vcs.File_contents.create "Hello" ]

let%expect_test "hash" =
  Hash_test.run (module Vcs.File_contents) (module Volgo_base.Vcs.File_contents) values;
  [%expect
    {|
    ({ value = "" }, { stdlib_hash = 0; vcs_hash = 0; vcs_base_hash = 0 })
    ({ value = ""; seed = 0 },
     { stdlib_hash = 0; vcs_hash = 0; vcs_base_hash = 0 })
    ({ value = ""; seed = 42 },
     { stdlib_hash = 142593372; vcs_hash = 142593372; vcs_base_hash = 142593372 })
    ({ value = "Hello" },
     { stdlib_hash = 200495445; vcs_hash = 200495445; vcs_base_hash = 200495445 })
    ({ value = "Hello"; seed = 0 },
     { stdlib_hash = 200495445; vcs_hash = 200495445; vcs_base_hash = 200495445 })
    ({ value = "Hello"; seed = 42 },
     { stdlib_hash = 825079905; vcs_hash = 825079905; vcs_base_hash = 825079905 })
    |}];
  ()
;;
