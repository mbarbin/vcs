(*******************************************************************************)
(*  Volgo - a Versatile OCaml Library for Git Operations                       *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
(*                                                                             *)
(*  This file is part of Volgo.                                                *)
(*                                                                             *)
(*  Volgo is free software; you can redistribute it and/or modify it under     *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Volgo is distributed in the hope that it will be useful, but WITHOUT ANY   *)
(*  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*  the file `NOTICE.md` at the root of this repository for more details.      *)
(*                                                                             *)
(*  You should have received a copy of the GNU Lesser General Public License   *)
(*  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*******************************************************************************)

(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024 Mathieu Barbin <mathieu.barbin@gmail.com>               *)
(*                                                                             *)
(*  This file is part of Vcs.                                                  *)
(*                                                                             *)
(*  Vcs is free software; you can redistribute it and/or modify it under       *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Vcs is distributed in the hope that it will be useful, but WITHOUT ANY     *)
(*  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*  the file `NOTICE.md` at the root of this repository for more details.      *)
(*                                                                             *)
(*  You should have received a copy of the GNU Lesser General Public License   *)
(*  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*******************************************************************************)

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
