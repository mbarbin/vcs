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

let values = [ Vcs.Repo_name.v "vcs"; Vcs.Repo_name.v "loc" ]

let%expect_test "hash" =
  Hash_test.run (module Vcs.Repo_name) (module Volgo_base.Vcs.Repo_name) values;
  [%expect
    {|
    ({ value = "vcs" },
     { stdlib_hash = 416069169; vcs_hash = 416069169; vcs_base_hash = 416069169 })
    ({ value = "vcs"; seed = 0 },
     { stdlib_hash = 416069169; vcs_hash = 416069169; vcs_base_hash = 416069169 })
    ({ value = "vcs"; seed = 42 },
     { stdlib_hash = 363610390; vcs_hash = 363610390; vcs_base_hash = 363610390 })
    ({ value = "loc" },
     { stdlib_hash = 41095261; vcs_hash = 41095261; vcs_base_hash = 41095261 })
    ({ value = "loc"; seed = 0 },
     { stdlib_hash = 41095261; vcs_hash = 41095261; vcs_base_hash = 41095261 })
    ({ value = "loc"; seed = 42 },
     { stdlib_hash = 683447793; vcs_hash = 683447793; vcs_base_hash = 683447793 })
    |}];
  ()
;;
