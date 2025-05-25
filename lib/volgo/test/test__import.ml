(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
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

module Import = Vcs.Private.Import

let%expect_test "Char.is_whitespace" =
  let test c ~expect =
    let is_whitespace = Import.Char.is_whitespace c in
    print_s [%sexp { char = (c : char); is_whitespace : bool }];
    require_equal [%here] (module Bool) is_whitespace expect
  in
  List.iter
    ~f:(fun c -> test c ~expect:true)
    [ ' '; '\t'; '\n'; '\011'; '\012'; '\r'; ' ' ];
  [%expect
    {|
    ((char          " ")
     (is_whitespace true))
    ((char          "\t")
     (is_whitespace true))
    ((char          "\n")
     (is_whitespace true))
    ((char          "\011")
     (is_whitespace true))
    ((char          "\012")
     (is_whitespace true))
    ((char          "\r")
     (is_whitespace true))
    ((char          " ")
     (is_whitespace true))
    |}];
  List.iter
    ~f:(fun c -> test c ~expect:false)
    [ 'a'; 'A'; '0'; '9'; 'z'; 'Z'; '1'; '8'; 'x'; 'X' ];
  [%expect
    {|
    ((char          a)
     (is_whitespace false))
    ((char          A)
     (is_whitespace false))
    ((char          0)
     (is_whitespace false))
    ((char          9)
     (is_whitespace false))
    ((char          z)
     (is_whitespace false))
    ((char          Z)
     (is_whitespace false))
    ((char          1)
     (is_whitespace false))
    ((char          8)
     (is_whitespace false))
    ((char          x)
     (is_whitespace false))
    ((char          X)
     (is_whitespace false))
    |}];
  ()
;;

let%expect_test "Int.to_string_hum" =
  let test i = print_endline (Import.Int.to_string_hum i) in
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

let%expect_test "Int_table.add_exn" =
  let module Int_table = Vcs.Private.Int_table in
  let table = Int_table.create 3 in
  Int_table.add_exn table ~key:1_234 ~data:"one";
  require_does_raise [%here] (fun () ->
    Int_table.add_exn table ~key:1_234 ~data:"one prime");
  [%expect {| ("Hashtbl.add_exn: key already present" ((key 1_234))) |}];
  ()
;;

let%expect_test "String.split_lines" =
  let test s =
    let lines = Import.String.split_lines s in
    print_s [%sexp (lines : string list)]
  in
  test "";
  [%expect {| () |}];
  test "\n";
  [%expect {| ("") |}];
  test "Hello\r\nWorld";
  [%expect {| (Hello World) |}];
  test "Hello\nWorld";
  [%expect {| (Hello World) |}];
  test "Hello\r\nWorld\r\n";
  [%expect {| (Hello World) |}];
  test "Hello\nWorld\n";
  [%expect {| (Hello World) |}];
  test "Hello\nWorld\n\n";
  [%expect {| (Hello World "") |}];
  ()
;;

let%expect_test "equal_list" =
  let test a b = Import.equal_list Int.equal a b in
  let r = [ 1; 2; 3 ] in
  require [%here] (test r r);
  require [%here] (test [ 1; 2; 3 ] [ 1; 2; 3 ]);
  require [%here] (test [] []);
  require [%here] (not (test [ 1; 2; 3 ] [ 1; 2 ]));
  require [%here] (not (test [ 1; 2; 3 ] [ 1; 2; 4 ]));
  require [%here] (not (test [] [ 1 ]));
  ()
;;
