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

module Bit_vector = struct
  type t = Fast_bitvector.t

  let sexp_of_t = Fast_bitvector.sexp_of_t

  let create ~len value : t =
    let t = Fast_bitvector.create ~len in
    let () = if value then Fast_bitvector.set_all t in
    t
  ;;

  let length = Fast_bitvector.length
  let set = Fast_bitvector.set_to
  let clear_all = Fast_bitvector.clear_all

  let intersect_in_place ~mutates other =
    if length mutates <> length other
    then invalid_arg "Bit_vector.intersect_in_place" [@coverage off];
    let (_ : Fast_bitvector.t) =
      Fast_bitvector.Set.intersect ~result:mutates mutates other
    in
    ()
  ;;
end

let%expect_test "intersect_in_place" =
  let v0 = Bit_vector.create ~len:10 true in
  print_s [%sexp (v0 : Bit_vector.t)];
  [%expect {| (LE 1111111111) |}];
  let v1 = Bit_vector.create ~len:10 false in
  print_s [%sexp (v1 : Bit_vector.t)];
  [%expect {| (LE 0000000000) |}];
  for i = 0 to Bit_vector.length v1 - 1 do
    if i % 2 = 0 then Bit_vector.set v1 i true
  done;
  Bit_vector.intersect_in_place ~mutates:v0 v1;
  print_s [%sexp (v0 : Bit_vector.t)];
  [%expect {| (LE 0101010101) |}];
  print_s [%sexp (v1 : Bit_vector.t)];
  [%expect {| (LE 0101010101) |}];
  Bit_vector.clear_all v1;
  for i = 0 to Bit_vector.length v1 - 1 do
    if i % 3 = 0 then Bit_vector.set v1 i true
  done;
  Bit_vector.intersect_in_place ~mutates:v0 v1;
  print_s [%sexp (v0 : Bit_vector.t)];
  [%expect {| (LE 0001000001) |}];
  print_s [%sexp (v1 : Bit_vector.t)];
  [%expect {| (LE 1001001001) |}];
  let vsmall = Bit_vector.create ~len:5 true in
  require_does_raise [%here] (fun () -> Bit_vector.intersect_in_place ~mutates:v0 vsmall);
  [%expect {| (Invalid_argument Bit_vector.intersect_in_place) |}];
  ()
;;
