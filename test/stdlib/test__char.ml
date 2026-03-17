(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "Char.is_whitespace" =
  let require c ~expect = require_equal (module Bool) (Char.is_whitespace c) expect in
  List.iter ~f:(fun c -> require c ~expect:true) [ ' '; '\t'; '\n'; '\011'; '\012'; '\r' ];
  List.iter
    ~f:(fun c -> require c ~expect:false)
    [ 'a'; 'A'; '0'; '9'; 'z'; 'Z'; '1'; '8'; 'x'; 'X' ];
  [%expect {||}];
  ()
;;
