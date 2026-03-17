(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let values = [ Vcs.Tag_name.v "my-tag"; Vcs.Tag_name.v "v0.0.1"; Vcs.Tag_name.v "1.2" ]

let%expect_test "hash" =
  Hash_test.run (module Vcs.Tag_name) (module Volgo_base.Vcs.Tag_name) values;
  [%expect
    {|
    ({ value = "my-tag" },
     { stdlib_hash = 865032536; vcs_hash = 865032536; vcs_base_hash = 865032536 })
    ({ value = "my-tag"; seed = 0 },
     { stdlib_hash = 865032536; vcs_hash = 865032536; vcs_base_hash = 865032536 })
    ({ value = "my-tag"; seed = 42 },
     { stdlib_hash = 809141036; vcs_hash = 809141036; vcs_base_hash = 809141036 })
    ({ value = "v0.0.1" },
     { stdlib_hash = 803999042; vcs_hash = 803999042; vcs_base_hash = 803999042 })
    ({ value = "v0.0.1"; seed = 0 },
     { stdlib_hash = 803999042; vcs_hash = 803999042; vcs_base_hash = 803999042 })
    ({ value = "v0.0.1"; seed = 42 },
     { stdlib_hash = 682119237; vcs_hash = 682119237; vcs_base_hash = 682119237 })
    ({ value = "1.2" },
     { stdlib_hash = 968236532; vcs_hash = 968236532; vcs_base_hash = 968236532 })
    ({ value = "1.2"; seed = 0 },
     { stdlib_hash = 968236532; vcs_hash = 968236532; vcs_base_hash = 968236532 })
    ({ value = "1.2"; seed = 42 },
     { stdlib_hash = 285020915; vcs_hash = 285020915; vcs_base_hash = 285020915 })
    |}];
  ()
;;
