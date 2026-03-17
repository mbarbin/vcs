(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let values = [ Vcs.User_handle.v "john-doe"; Vcs.User_handle.v "jane-doe" ]

let%expect_test "hash" =
  Hash_test.run (module Vcs.User_handle) (module Volgo_base.Vcs.User_handle) values;
  [%expect
    {|
    ({ value = "john-doe" },
     { stdlib_hash = 152607077; vcs_hash = 152607077; vcs_base_hash = 152607077 })
    ({ value = "john-doe"; seed = 0 },
     { stdlib_hash = 152607077; vcs_hash = 152607077; vcs_base_hash = 152607077 })
    ({ value = "john-doe"; seed = 42 },
     { stdlib_hash = 80938851; vcs_hash = 80938851; vcs_base_hash = 80938851 })
    ({ value = "jane-doe" },
     { stdlib_hash = 209935393; vcs_hash = 209935393; vcs_base_hash = 209935393 })
    ({ value = "jane-doe"; seed = 0 },
     { stdlib_hash = 209935393; vcs_hash = 209935393; vcs_base_hash = 209935393 })
    ({ value = "jane-doe"; seed = 42 },
     { stdlib_hash = 414759229; vcs_hash = 414759229; vcs_base_hash = 414759229 })
    |}];
  ()
;;
