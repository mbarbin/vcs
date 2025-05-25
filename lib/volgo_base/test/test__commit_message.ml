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

let values =
  [ Vcs.Commit_message.v "Add this awesome new feature"
  ; Vcs.Commit_message.v "Fix this rather annoying bug"
  ]
;;

let%expect_test "hash" =
  Hash_test.run (module Vcs.Commit_message) (module Volgo_base.Vcs.Commit_message) values;
  [%expect
    {|
    (((value "Add this awesome new feature"))
     ((stdlib_hash   340930455)
      (vcs_hash      340930455)
      (vcs_base_hash 340930455)))
    (((value "Add this awesome new feature")
      (seed  0))
     ((stdlib_hash   340930455)
      (vcs_hash      340930455)
      (vcs_base_hash 340930455)))
    (((value "Add this awesome new feature")
      (seed  42))
     ((stdlib_hash   655507996)
      (vcs_hash      655507996)
      (vcs_base_hash 655507996)))
    (((value "Fix this rather annoying bug"))
     ((stdlib_hash   410910191)
      (vcs_hash      410910191)
      (vcs_base_hash 410910191)))
    (((value "Fix this rather annoying bug")
      (seed  0))
     ((stdlib_hash   410910191)
      (vcs_hash      410910191)
      (vcs_base_hash 410910191)))
    (((value "Fix this rather annoying bug")
      (seed  42))
     ((stdlib_hash   813233200)
      (vcs_hash      813233200)
      (vcs_base_hash 813233200)))
    |}];
  ()
;;
