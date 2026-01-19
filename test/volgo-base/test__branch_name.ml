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

let values = [ Vcs.Branch_name.main; Vcs.Branch_name.v "my-branch" ]

let%expect_test "hash" =
  Hash_test.run (module Vcs.Branch_name) (module Volgo_base.Vcs.Branch_name) values;
  [%expect
    {|
    (((value main))
     ((stdlib_hash 763421968) (vcs_hash 763421968) (vcs_base_hash 763421968)))
    (((value main) (seed 0))
     ((stdlib_hash 763421968) (vcs_hash 763421968) (vcs_base_hash 763421968)))
    (((value main) (seed 42))
     ((stdlib_hash 1007953461) (vcs_hash 1007953461) (vcs_base_hash 1007953461)))
    (((value my-branch))
     ((stdlib_hash 977970132) (vcs_hash 977970132) (vcs_base_hash 977970132)))
    (((value my-branch) (seed 0))
     ((stdlib_hash 977970132) (vcs_hash 977970132) (vcs_base_hash 977970132)))
    (((value my-branch) (seed 42))
     ((stdlib_hash 513500652) (vcs_hash 513500652) (vcs_base_hash 513500652)))
    |}];
  ()
;;
