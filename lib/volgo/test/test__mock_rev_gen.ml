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

let%expect_test "next" =
  let next t =
    let rev = Vcs.Mock_rev_gen.next t in
    print_s [%sexp (rev : Vcs.Rev.t)];
    rev
  in
  let t1 = Vcs.Mock_rev_gen.create ~name:"test-01" in
  let r1_1 = next t1 in
  [%expect {| 3a17020189a3e2f321812d06dcd18f173a170201 |}];
  let r1_2 = next t1 in
  [%expect {| 5311cc2b07a9429689e0cdfaf03638d65311cc2b |}];
  let r1_3 = next t1 in
  [%expect {| 37b01b20ef41eafea0aedad8a6dcde1837b01b20 |}];
  let t2 = Vcs.Mock_rev_gen.create ~name:"test-02" in
  let r2_1 = next t2 in
  [%expect {| e0feef2049128bdce931034505a364afe0feef20 |}];
  let r2_2 = next t2 in
  [%expect {| 9c74009b6f530cb336b744096a2c603d9c74009b |}];
  let r2_3 = next t2 in
  [%expect {| 9d0ab8899468763d0190656533a4222b9d0ab889 |}];
  let all =
    List.dedup_and_sort [ r1_1; r1_2; r1_3; r2_1; r2_2; r2_3 ] ~compare:Vcs.Rev.compare
  in
  require_equal [%here] (module Int) (List.length all) 6;
  (* The same rev can be recreated from the same state. *)
  let t3 = Vcs.Mock_rev_gen.create ~name:"test-01" in
  let r3_1 = next t3 in
  [%expect {| 3a17020189a3e2f321812d06dcd18f173a170201 |}];
  let r3_2 = next t3 in
  [%expect {| 5311cc2b07a9429689e0cdfaf03638d65311cc2b |}];
  let r3_3 = next t3 in
  [%expect {| 37b01b20ef41eafea0aedad8a6dcde1837b01b20 |}];
  require
    [%here]
    (List.for_all
       [ r1_1, r3_1; r1_2, r3_2; r1_3, r3_3 ]
       ~f:(fun (a, b) -> Vcs.Rev.equal a b));
  ()
;;
