(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let values =
  List.concat_map Test__remote_name.values ~f:(fun remote_name ->
    List.map Test__branch_name.values ~f:(fun branch_name ->
      { Vcs.Remote_branch_name.remote_name; branch_name }))
;;

let%expect_test "hash" =
  Hash_test.run
    (module Vcs.Remote_branch_name)
    (module Volgo_base.Vcs.Remote_branch_name)
    values;
  [%expect
    {|
    ({ value = { remote_name = "origin"; branch_name = "main" } },
     { stdlib_hash = 310768421; vcs_hash = 310768421; vcs_base_hash = 299265207 })
    ({ value = { remote_name = "origin"; branch_name = "main" }; seed = 0 },
     { stdlib_hash = 310768421; vcs_hash = 310768421; vcs_base_hash = 299265207 })
    ({ value = { remote_name = "origin"; branch_name = "main" }; seed = 42 },
     { stdlib_hash = 1032210503
     ; vcs_hash = 1032210503
     ; vcs_base_hash = 701314591
     })
    ({ value = { remote_name = "origin"; branch_name = "my-branch" } },
     { stdlib_hash = 598970259; vcs_hash = 598970259; vcs_base_hash = 239096173 })
    ({ value = { remote_name = "origin"; branch_name = "my-branch" }; seed = 0 },
     { stdlib_hash = 598970259; vcs_hash = 598970259; vcs_base_hash = 239096173 })
    ({ value = { remote_name = "origin"; branch_name = "my-branch" }; seed = 42 },
     { stdlib_hash = 46891672; vcs_hash = 46891672; vcs_base_hash = 1039200790 })
    ({ value = { remote_name = "upstream"; branch_name = "main" } },
     { stdlib_hash = 588793325; vcs_hash = 588793325; vcs_base_hash = 919801467 })
    ({ value = { remote_name = "upstream"; branch_name = "main" }; seed = 0 },
     { stdlib_hash = 588793325; vcs_hash = 588793325; vcs_base_hash = 919801467 })
    ({ value = { remote_name = "upstream"; branch_name = "main" }; seed = 42 },
     { stdlib_hash = 698319882; vcs_hash = 698319882; vcs_base_hash = 760806345 })
    ({ value = { remote_name = "upstream"; branch_name = "my-branch" } },
     { stdlib_hash = 925005510; vcs_hash = 925005510; vcs_base_hash = 470939564 })
    ({ value = { remote_name = "upstream"; branch_name = "my-branch" }
     ; seed = 0
     },
     { stdlib_hash = 925005510; vcs_hash = 925005510; vcs_base_hash = 470939564 })
    ({ value = { remote_name = "upstream"; branch_name = "my-branch" }
     ; seed = 42
     },
     { stdlib_hash = 990156454; vcs_hash = 990156454; vcs_base_hash = 260501276 })
    |}];
  ()
;;
