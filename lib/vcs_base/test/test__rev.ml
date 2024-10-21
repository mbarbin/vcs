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

let%expect_test "hash" =
  let mock_rev_gen = Vcs.Mock_rev_gen.create ~name:"test-graph" in
  let rev () = Vcs.Mock_rev_gen.next mock_rev_gen in
  let values = [ rev (); rev () ] in
  Hash_test.run (module Vcs.Rev) (module Vcs_base.Vcs.Rev) values;
  [%expect
    {|
    (((value f453b802f640c6888df978c712057d17f453b802))
     ((stdlib_hash   1067342185)
      (vcs_hash      1067342185)
      (vcs_base_hash 1067342185)))
    (((value f453b802f640c6888df978c712057d17f453b802)
      (seed  0))
     ((stdlib_hash   1067342185)
      (vcs_hash      1067342185)
      (vcs_base_hash 1067342185)))
    (((value f453b802f640c6888df978c712057d17f453b802)
      (seed  42))
     ((stdlib_hash   720223438)
      (vcs_hash      720223438)
      (vcs_base_hash 720223438)))
    (((value 5cd237e9598b11065c344d1eb33bc8c15cd237e9))
     ((stdlib_hash   687820538)
      (vcs_hash      687820538)
      (vcs_base_hash 687820538)))
    (((value 5cd237e9598b11065c344d1eb33bc8c15cd237e9)
      (seed  0))
     ((stdlib_hash   687820538)
      (vcs_hash      687820538)
      (vcs_base_hash 687820538)))
    (((value 5cd237e9598b11065c344d1eb33bc8c15cd237e9)
      (seed  42))
     ((stdlib_hash   1058957186)
      (vcs_hash      1058957186)
      (vcs_base_hash 1058957186)))
    |}];
  ()
;;