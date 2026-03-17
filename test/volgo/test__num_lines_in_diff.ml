(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "zero" =
  print_dyn (Vcs.Num_lines_in_diff.zero |> Vcs.Num_lines_in_diff.to_dyn);
  [%expect {| { insertions = 0; deletions = 0 } |}];
  require (Vcs.Num_lines_in_diff.is_zero Vcs.Num_lines_in_diff.zero);
  [%expect {||}];
  require_equal (module Int) (Vcs.Num_lines_in_diff.total Vcs.Num_lines_in_diff.zero) 0;
  [%expect {||}];
  require_equal
    (module Vcs.Num_lines_in_diff)
    Vcs.Num_lines_in_diff.zero
    Vcs.Num_lines_in_diff.(zero + zero);
  [%expect {||}];
  print_endline (Vcs.Num_lines_in_diff.to_string_hum Vcs.Num_lines_in_diff.zero);
  [%expect {| 0 |}];
  ()
;;

let%expect_test "add" =
  let t1 = { Vcs.Num_lines_in_diff.insertions = 1; deletions = 2 } in
  let t2 = { Vcs.Num_lines_in_diff.insertions = 3; deletions = 4 } in
  print_dyn (Vcs.Num_lines_in_diff.(t1 + t2) |> Vcs.Num_lines_in_diff.to_dyn);
  [%expect {| { insertions = 4; deletions = 6 } |}];
  require_equal
    (module Vcs.Num_lines_in_diff)
    { Vcs.Num_lines_in_diff.insertions = 4; deletions = 6 }
    Vcs.Num_lines_in_diff.(t1 + t2);
  [%expect {||}];
  print_dyn (Vcs.Num_lines_in_diff.sum [ t1; t2 ] |> Vcs.Num_lines_in_diff.to_dyn);
  [%expect {| { insertions = 4; deletions = 6 } |}];
  ()
;;

let%expect_test "total" =
  let t1 = { Vcs.Num_lines_in_diff.insertions = 1; deletions = 2 } in
  print_dyn (Vcs.Num_lines_in_diff.total t1 |> Dyn.int);
  [%expect {| 3 |}];
  ()
;;

let%expect_test "to_string_hum" =
  let test t = print_endline (Vcs.Num_lines_in_diff.to_string_hum t) in
  test { insertions = 0; deletions = 0 };
  [%expect {| 0 |}];
  test { insertions = 100; deletions = 0 };
  [%expect {| +100 |}];
  test { insertions = 0; deletions = 15 };
  [%expect {| -15 |}];
  test { insertions = 1999; deletions = 13898 };
  [%expect {| +1_999, -13_898 |}];
  ()
;;

let%expect_test "equal-and-compare" =
  let t1 = { Vcs.Num_lines_in_diff.insertions = 1; deletions = 2 } in
  let t2 = { Vcs.Num_lines_in_diff.insertions = 1; deletions = 2 } in
  let t3 = { Vcs.Num_lines_in_diff.insertions = 1; deletions = 3 } in
  let t4 = { Vcs.Num_lines_in_diff.insertions = 2; deletions = 2 } in
  require_equal (module Vcs.Num_lines_in_diff) t1 t1;
  [%expect {||}];
  require_equal (module Vcs.Num_lines_in_diff) t1 t2;
  [%expect {||}];
  require_not_equal (module Vcs.Num_lines_in_diff) t1 t3;
  [%expect {||}];
  require_not_equal (module Vcs.Num_lines_in_diff) t1 t4;
  [%expect {||}];
  let cmp a b =
    print_dyn (Vcs.Num_lines_in_diff.compare a b |> Ordering.of_int |> Ordering.to_dyn)
  in
  cmp t1 t1;
  [%expect {| Eq |}];
  cmp t1 t2;
  [%expect {| Eq |}];
  cmp t1 t3;
  [%expect {| Lt |}];
  cmp t1 t4;
  [%expect {| Lt |}];
  cmp t4 t1;
  [%expect {| Gt |}];
  ()
;;

let%expect_test "sexp_of_t" =
  let test t = print_s (t |> Vcs.Num_lines_in_diff.sexp_of_t) in
  test { insertions = 42; deletions = 32 };
  [%expect {| ((insertions 42) (deletions 32)) |}];
  ()
;;
