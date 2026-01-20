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
