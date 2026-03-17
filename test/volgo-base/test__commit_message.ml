(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let values =
  [ Vcs.Commit_message.v "Add this awesome new feature"
  ; Vcs.Commit_message.v "Fix this rather annoying bug"
  ]
;;

let%expect_test "hash" =
  Hash_test.run (module Vcs.Commit_message) (module Volgo_base.Vcs.Commit_message) values;
  [%expect
    {|
    ({ value = "Add this awesome new feature" },
     { stdlib_hash = 340930455; vcs_hash = 340930455; vcs_base_hash = 340930455 })
    ({ value = "Add this awesome new feature"; seed = 0 },
     { stdlib_hash = 340930455; vcs_hash = 340930455; vcs_base_hash = 340930455 })
    ({ value = "Add this awesome new feature"; seed = 42 },
     { stdlib_hash = 655507996; vcs_hash = 655507996; vcs_base_hash = 655507996 })
    ({ value = "Fix this rather annoying bug" },
     { stdlib_hash = 410910191; vcs_hash = 410910191; vcs_base_hash = 410910191 })
    ({ value = "Fix this rather annoying bug"; seed = 0 },
     { stdlib_hash = 410910191; vcs_hash = 410910191; vcs_base_hash = 410910191 })
    ({ value = "Fix this rather annoying bug"; seed = 42 },
     { stdlib_hash = 813233200; vcs_hash = 813233200; vcs_base_hash = 813233200 })
    |}];
  ()
;;
