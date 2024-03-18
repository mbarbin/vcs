(*******************************************************************************)
(*  Vcs - a versatile OCaml library for Git interaction                        *)
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

let%expect_test "to_string" =
  let test t = print_endline (Vcs.Ref_kind.to_string t) in
  test (Local_branch { branch_name = Vcs.Branch_name.main });
  [%expect {| refs/heads/main |}];
  test (Remote_branch { remote_branch_name = Vcs.Remote_branch_name.v "origin/main" });
  [%expect {| refs/remotes/origin/main |}];
  test (Tag { tag_name = Vcs.Tag_name.v "0.1.3" });
  [%expect {| refs/tags/0.1.3 |}];
  test (Other { name = "name" });
  [%expect {| refs/name |}];
  ()
;;
