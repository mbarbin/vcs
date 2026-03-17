(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "hash" =
  let mock_rev_gen = Vcs.Mock_rev_gen.create ~name:"test-graph" in
  let rev () = Vcs.Mock_rev_gen.next mock_rev_gen in
  let values = [ rev (); rev () ] in
  Hash_test.run (module Vcs.Rev) (module Volgo_base.Vcs.Rev) values;
  [%expect
    {|
    ({ value = "f453b802f640c6888df978c712057d17f453b802" },
     { stdlib_hash = 1067342185
     ; vcs_hash = 1067342185
     ; vcs_base_hash = 1067342185
     })
    ({ value = "f453b802f640c6888df978c712057d17f453b802"; seed = 0 },
     { stdlib_hash = 1067342185
     ; vcs_hash = 1067342185
     ; vcs_base_hash = 1067342185
     })
    ({ value = "f453b802f640c6888df978c712057d17f453b802"; seed = 42 },
     { stdlib_hash = 720223438; vcs_hash = 720223438; vcs_base_hash = 720223438 })
    ({ value = "5cd237e9598b11065c344d1eb33bc8c15cd237e9" },
     { stdlib_hash = 687820538; vcs_hash = 687820538; vcs_base_hash = 687820538 })
    ({ value = "5cd237e9598b11065c344d1eb33bc8c15cd237e9"; seed = 0 },
     { stdlib_hash = 687820538; vcs_hash = 687820538; vcs_base_hash = 687820538 })
    ({ value = "5cd237e9598b11065c344d1eb33bc8c15cd237e9"; seed = 42 },
     { stdlib_hash = 1058957186
     ; vcs_hash = 1058957186
     ; vcs_base_hash = 1058957186
     })
    |}];
  ()
;;
