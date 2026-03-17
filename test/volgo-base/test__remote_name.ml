(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let values = [ Vcs.Remote_name.origin; Vcs.Remote_name.v "upstream" ]

let%expect_test "hash" =
  Hash_test.run (module Vcs.Remote_name) (module Volgo_base.Vcs.Remote_name) values;
  [%expect
    {|
    ({ value = "origin" },
     { stdlib_hash = 340153502; vcs_hash = 340153502; vcs_base_hash = 340153502 })
    ({ value = "origin"; seed = 0 },
     { stdlib_hash = 340153502; vcs_hash = 340153502; vcs_base_hash = 340153502 })
    ({ value = "origin"; seed = 42 },
     { stdlib_hash = 84167816; vcs_hash = 84167816; vcs_base_hash = 84167816 })
    ({ value = "upstream" },
     { stdlib_hash = 315569492; vcs_hash = 315569492; vcs_base_hash = 315569492 })
    ({ value = "upstream"; seed = 0 },
     { stdlib_hash = 315569492; vcs_hash = 315569492; vcs_base_hash = 315569492 })
    ({ value = "upstream"; seed = 42 },
     { stdlib_hash = 96936268; vcs_hash = 96936268; vcs_base_hash = 96936268 })
    |}];
  ()
;;
