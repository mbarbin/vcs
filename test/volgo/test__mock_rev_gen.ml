(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "next" =
  let next t =
    let rev = Vcs.Mock_rev_gen.next t in
    print_dyn (rev |> Vcs.Rev.to_dyn);
    rev
  in
  let t1 = Vcs.Mock_rev_gen.create ~name:"test-01" in
  let r1_1 = next t1 in
  [%expect {| "3a17020189a3e2f321812d06dcd18f173a170201" |}];
  let r1_2 = next t1 in
  [%expect {| "5311cc2b07a9429689e0cdfaf03638d65311cc2b" |}];
  let r1_3 = next t1 in
  [%expect {| "37b01b20ef41eafea0aedad8a6dcde1837b01b20" |}];
  let t2 = Vcs.Mock_rev_gen.create ~name:"test-02" in
  let r2_1 = next t2 in
  [%expect {| "e0feef2049128bdce931034505a364afe0feef20" |}];
  let r2_2 = next t2 in
  [%expect {| "9c74009b6f530cb336b744096a2c603d9c74009b" |}];
  let r2_3 = next t2 in
  [%expect {| "9d0ab8899468763d0190656533a4222b9d0ab889" |}];
  let all =
    List.dedup_and_sort [ r1_1; r1_2; r1_3; r2_1; r2_2; r2_3 ] ~compare:Vcs.Rev.compare
  in
  require_equal (module Int) (List.length all) 6;
  (* The same rev can be recreated from the same state. *)
  let t3 = Vcs.Mock_rev_gen.create ~name:"test-01" in
  let r3_1 = next t3 in
  [%expect {| "3a17020189a3e2f321812d06dcd18f173a170201" |}];
  let r3_2 = next t3 in
  [%expect {| "5311cc2b07a9429689e0cdfaf03638d65311cc2b" |}];
  let r3_3 = next t3 in
  [%expect {| "37b01b20ef41eafea0aedad8a6dcde1837b01b20" |}];
  require
    (List.for_all
       [ r1_1, r3_1; r1_2, r3_2; r1_3, r3_3 ]
       ~f:(fun (a, b) -> Vcs.Rev.equal a b));
  ()
;;
