(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let values = [ Vcs.Path_in_repo.v "foo.txt"; Vcs.Path_in_repo.v "bar/baz.ml" ]

let%expect_test "hash" =
  Hash_test.run (module Vcs.Path_in_repo) (module Volgo_base.Vcs.Path_in_repo) values;
  [%expect
    {|
    ({ value = "foo.txt" },
     { stdlib_hash = 836355526; vcs_hash = 836355526; vcs_base_hash = 836355526 })
    ({ value = "foo.txt"; seed = 0 },
     { stdlib_hash = 836355526; vcs_hash = 836355526; vcs_base_hash = 836355526 })
    ({ value = "foo.txt"; seed = 42 },
     { stdlib_hash = 444099220; vcs_hash = 444099220; vcs_base_hash = 444099220 })
    ({ value = "bar/baz.ml" },
     { stdlib_hash = 615308050; vcs_hash = 615308050; vcs_base_hash = 615308050 })
    ({ value = "bar/baz.ml"; seed = 0 },
     { stdlib_hash = 615308050; vcs_hash = 615308050; vcs_base_hash = 615308050 })
    ({ value = "bar/baz.ml"; seed = 42 },
     { stdlib_hash = 922480314; vcs_hash = 922480314; vcs_base_hash = 922480314 })
    |}];
  ()
;;
