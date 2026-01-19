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

let%expect_test "sexp_of_t" =
  print_s [%sexp (Err.create [ Err.sexp [%sexp Hello] ] : Err.t)];
  [%expect {| Hello |}];
  print_s
    [%sexp
      (Err.add_context (Err.create [ Err.sexp [%sexp Hello] ]) [ Err.sexp [%sexp Step] ]
       : Err.t)];
  [%expect {| ((context Step) (error Hello)) |}];
  print_s [%sexp (Err.create [ Pp.verbatim "Hello" ] : Err.t)];
  [%expect {| Hello |}];
  print_s [%sexp (Err.create [ Pp.text "Hello"; Err.sexp [%sexp Step] ] : Err.t)];
  [%expect {| (Hello Step) |}];
  print_s [%sexp (Err.create Pp.O.[ Pp.text "Hello " ++ Err.sexp [%sexp Step] ] : Err.t)];
  [%expect {| "Hello Step" |}];
  ()
;;

let%expect_test "to_string_hum" =
  print_endline (Err.to_string_hum (Err.create [ Err.sexp [%sexp Hello] ]));
  [%expect {| Hello |}];
  print_endline (Err.to_string_hum (Err.create [ Pp.verbatim "Hello" ]));
  [%expect {| Hello |}];
  ()
;;

let%expect_test "error_string" =
  let err = Err.create [ Pp.text "error message" ] in
  print_endline (Err.to_string_hum err);
  [%expect {| "error message" |}];
  print_s [%sexp (err : Err.t)];
  [%expect {| "error message" |}];
  ()
;;

let%expect_test "of_exn" =
  let err = Err.of_exn (Failure "exn message") in
  print_endline (Err.to_string_hum err);
  [%expect {| (Failure "exn message") |}];
  print_s [%sexp (err : Err.t)];
  [%expect {| (Failure "exn message") |}];
  let err = Err.of_exn (Invalid_argument "exn message") in
  print_endline (Err.to_string_hum err);
  [%expect {| (Invalid_argument "exn message") |}];
  print_s [%sexp (err : Err.t)];
  [%expect {| (Invalid_argument "exn message") |}];
  ()
;;

let%expect_test "add_context" =
  let err = Err.create [ Pp.verbatim "Hello" ] in
  print_s [%sexp (err : Err.t)];
  [%expect {| Hello |}];
  let err = Err.add_context err [ Pp.verbatim "Step_1" ] in
  print_s [%sexp (err : Err.t)];
  [%expect {| ((context Step_1) (error Hello)) |}];
  let err = Err.add_context err [ Err.sexp [%sexp Step_2, { x = 42 }] ] in
  print_s [%sexp (err : Err.t)];
  [%expect {| ((context (Step_2 ((x 42))) Step_1) (error Hello)) |}];
  ()
;;

let%expect_test "init" =
  print_s
    [%sexp (Err.add_context (Err.create [ Pp.text "Hello" ]) [ Pp.text "Step" ] : Err.t)];
  [%expect {| ((context Step) (error Hello)) |}];
  ()
;;
