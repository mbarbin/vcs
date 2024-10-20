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

let%expect_test "zero" =
  print_s [%sexp (Vcs.Num_lines_in_diff.zero : Vcs.Num_lines_in_diff.t)];
  [%expect {|
    ((insertions 0)
     (deletions  0)) |}];
  require [%here] (Vcs.Num_lines_in_diff.is_zero Vcs.Num_lines_in_diff.zero);
  [%expect {||}];
  require_equal
    [%here]
    (module Int)
    (Vcs.Num_lines_in_diff.total Vcs.Num_lines_in_diff.zero)
    0;
  [%expect {||}];
  require_equal
    [%here]
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
  print_s [%sexp (Vcs.Num_lines_in_diff.(t1 + t2) : Vcs.Num_lines_in_diff.t)];
  [%expect {|
    ((insertions 4)
     (deletions  6)) |}];
  require_equal
    [%here]
    (module Vcs.Num_lines_in_diff)
    { Vcs.Num_lines_in_diff.insertions = 4; deletions = 6 }
    Vcs.Num_lines_in_diff.(t1 + t2);
  [%expect {||}];
  print_s [%sexp (Vcs.Num_lines_in_diff.sum [ t1; t2 ] : Vcs.Num_lines_in_diff.t)];
  [%expect {|
    ((insertions 4)
     (deletions  6)) |}];
  ()
;;

let%expect_test "total" =
  let t1 = { Vcs.Num_lines_in_diff.insertions = 1; deletions = 2 } in
  print_s [%sexp (Vcs.Num_lines_in_diff.total t1 : int)];
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
  [%expect {| +1,999, -13,898 |}];
  ()
;;

let%expect_test "equal-and-compare" =
  let t1 = { Vcs.Num_lines_in_diff.insertions = 1; deletions = 2 } in
  let t2 = { Vcs.Num_lines_in_diff.insertions = 1; deletions = 2 } in
  let t3 = { Vcs.Num_lines_in_diff.insertions = 1; deletions = 3 } in
  let t4 = { Vcs.Num_lines_in_diff.insertions = 2; deletions = 2 } in
  require_equal [%here] (module Vcs.Num_lines_in_diff) t1 t1;
  [%expect {||}];
  require_equal [%here] (module Vcs.Num_lines_in_diff) t1 t2;
  [%expect {||}];
  require_not_equal [%here] (module Vcs.Num_lines_in_diff) t1 t3;
  [%expect {||}];
  require_not_equal [%here] (module Vcs.Num_lines_in_diff) t1 t4;
  [%expect {||}];
  let cmp a b =
    print_s [%sexp (Vcs.Num_lines_in_diff.compare a b |> Ordering.of_int : Ordering.t)]
  in
  cmp t1 t1;
  [%expect {| Equal |}];
  cmp t1 t2;
  [%expect {| Equal |}];
  cmp t1 t3;
  [%expect {| Less |}];
  cmp t1 t4;
  [%expect {| Less |}];
  ()
;;
