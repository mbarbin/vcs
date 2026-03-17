(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let values = [ Vcs.User_email.v "jdoe@jdoe.org"; Vcs.User_email.v "john-doe@email.com" ]

let%expect_test "hash" =
  Hash_test.run (module Vcs.User_email) (module Volgo_base.Vcs.User_email) values;
  [%expect
    {|
    ({ value = "jdoe@jdoe.org" },
     { stdlib_hash = 505986774; vcs_hash = 505986774; vcs_base_hash = 505986774 })
    ({ value = "jdoe@jdoe.org"; seed = 0 },
     { stdlib_hash = 505986774; vcs_hash = 505986774; vcs_base_hash = 505986774 })
    ({ value = "jdoe@jdoe.org"; seed = 42 },
     { stdlib_hash = 249313671; vcs_hash = 249313671; vcs_base_hash = 249313671 })
    ({ value = "john-doe@email.com" },
     { stdlib_hash = 641234243; vcs_hash = 641234243; vcs_base_hash = 641234243 })
    ({ value = "john-doe@email.com"; seed = 0 },
     { stdlib_hash = 641234243; vcs_hash = 641234243; vcs_base_hash = 641234243 })
    ({ value = "john-doe@email.com"; seed = 42 },
     { stdlib_hash = 810806416; vcs_hash = 810806416; vcs_base_hash = 810806416 })
    |}];
  ()
;;
