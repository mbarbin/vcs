(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

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
