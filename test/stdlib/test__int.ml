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

let%expect_test "Int.to_string_hum" =
  let test i = print_endline (Int.to_string_hum i) in
  List.iter
    ~f:test
    [ 0
    ; 42
    ; 421
    ; 1_234
    ; 12_345
    ; 123_456
    ; 1_234_567
    ; 12_345_678
    ; -3
    ; -99
    ; -123
    ; -1_234
    ; -12_345
    ; -123_456
    ; -1_234_567
    ; -12_345_678
    ];
  [%expect
    {|
    0
    42
    421
    1_234
    12_345
    123_456
    1_234_567
    12_345_678
    -3
    -99
    -123
    -1_234
    -12_345
    -123_456
    -1_234_567
    -12_345_678
    |}];
  ()
;;

let%expect_test "to_dyn" =
  let test i = print_dyn (Int.to_dyn i) in
  test 123_456;
  [%expect {| 123456 |}];
  ()
;;
