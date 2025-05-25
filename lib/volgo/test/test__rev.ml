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

let%expect_test "of_string" =
  let test str =
    print_s [%sexp (Vcs.Rev.of_string str : (Vcs.Rev.t, [ `Msg of string ]) Result.t)]
  in
  test "";
  [%expect {| (Error (Msg "\"\": invalid rev")) |}];
  test "too-short";
  [%expect {| (Error (Msg "\"too-short\": invalid rev")) |}];
  test "3a17020189a3e2f321812d06dcd18f173a170201";
  [%expect {| (Ok 3a17020189a3e2f321812d06dcd18f173a170201) |}];
  test "3a17020189a3e2f321812d06dcd18f173a170201";
  [%expect {| (Ok 3a17020189a3e2f321812d06dcd18f173a170201) |}];
  (* Currently we don't enforce much but the length of the string, and the kind
     of chars that it contains. *)
  test "this-string-is-not-a-rev-but-it-is-valid";
  [%expect {| (Ok this-string-is-not-a-rev-but-it-is-valid) |}];
  test (String.make 40 ' ');
  [%expect
    {| (Error (Msg "\"                                        \": invalid rev")) |}];
  ()
;;
