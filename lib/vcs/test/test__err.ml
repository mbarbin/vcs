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

let%expect_test "sexp_of_t" =
  print_s [%sexp (Vcs.Err.create_s [%sexp Hello] : Vcs.Err.t)];
  [%expect {| Hello |}];
  print_s [%sexp (Vcs.Err.init [%sexp Hello] ~step:[%sexp Step] : Vcs.Err.t)];
  [%expect {| ((steps (Step)) (error Hello)) |}];
  ()
;;

let%expect_test "to_string_hum" =
  print_endline (Vcs.Err.to_string_hum (Vcs.Err.create_s [%sexp Hello]));
  [%expect {| Hello |}];
  ()
;;

let%expect_test "error_string" =
  let err = Vcs.Err.error_string "error message" in
  print_endline (Vcs.Err.to_string_hum err);
  [%expect {| "error message" |}];
  print_s [%sexp (err : Vcs.Err.t)];
  [%expect {| "error message" |}];
  ()
;;

let%expect_test "of_exn" =
  let err = Vcs.Err.of_exn (Failure "exn message") in
  print_endline (Vcs.Err.to_string_hum err);
  [%expect {| (Failure "exn message") |}];
  print_s [%sexp (err : Vcs.Err.t)];
  [%expect {| (Failure "exn message") |}];
  let err = Vcs.Err.of_exn (Invalid_argument "exn message") in
  print_endline (Vcs.Err.to_string_hum err);
  [%expect {| (Invalid_argument "exn message") |}];
  print_s [%sexp (err : Vcs.Err.t)];
  [%expect {| (Invalid_argument "exn message") |}];
  ()
;;

let%expect_test "add_context" =
  let err = Vcs.Err.create_s [%sexp Hello] in
  print_s [%sexp (err : Vcs.Err.t)];
  [%expect {| Hello |}];
  let err = Vcs.Err.add_context err ~step:[%sexp Step_1] in
  print_s [%sexp (err : Vcs.Err.t)];
  [%expect {| ((steps (Step_1)) (error Hello)) |}];
  let err = Vcs.Err.add_context err ~step:[%sexp Step_2, { x = 42 }] in
  print_s [%sexp (err : Vcs.Err.t)];
  [%expect {| ((steps ((Step_2 ((x 42))) Step_1)) (error Hello)) |}];
  ()
;;

let%expect_test "init" =
  print_s [%sexp (Vcs.Err.init [%sexp Hello] ~step:[%sexp Step] : Vcs.Err.t)];
  [%expect {| ((steps (Step)) (error Hello)) |}];
  ()
;;
