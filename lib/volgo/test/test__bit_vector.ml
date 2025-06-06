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

module Bit_vector = Vcs.Private.Bit_vector

let%expect_test "bw_and_inplace" =
  let v0 = Bit_vector.create ~len:10 true in
  print_s [%sexp (v0 : Bit_vector.t)];
  [%expect {| 1111111111 |}];
  let v1 = Bit_vector.create ~len:10 false in
  print_s [%sexp (v1 : Bit_vector.t)];
  [%expect {| 0000000000 |}];
  for i = 0 to Bit_vector.length v1 - 1 do
    if i % 2 = 0 then Bit_vector.set v1 i true
  done;
  Bit_vector.bw_and_in_place ~mutates:v0 v1;
  print_s [%sexp (v0 : Bit_vector.t)];
  [%expect {| 1010101010 |}];
  print_s [%sexp (v1 : Bit_vector.t)];
  [%expect {| 1010101010 |}];
  Bit_vector.reset v1 false;
  for i = 0 to Bit_vector.length v1 - 1 do
    if i % 3 = 0 then Bit_vector.set v1 i true
  done;
  Bit_vector.bw_and_in_place ~mutates:v0 v1;
  print_s [%sexp (v0 : Bit_vector.t)];
  [%expect {| 1000001000 |}];
  print_s [%sexp (v1 : Bit_vector.t)];
  [%expect {| 1001001001 |}];
  let vsmall = Bit_vector.create ~len:5 true in
  require_does_raise [%here] (fun () -> Bit_vector.bw_and_in_place ~mutates:v0 vsmall);
  [%expect {| (Invalid_argument Bit_vector.bw_and_in_place) |}];
  ()
;;
