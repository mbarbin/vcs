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

module Bitv = struct
  include Bitv

  let to_dyn t = Dyn.string (Bitv.L.to_string t)
end

let%expect_test "bw_and_in_place" =
  let v0 = Bitv.create 10 true in
  print_dyn (v0 |> Bitv.to_dyn);
  [%expect {| "1111111111" |}];
  let v1 = Bitv.create 10 false in
  print_dyn (v1 |> Bitv.to_dyn);
  [%expect {| "0000000000" |}];
  for i = 0 to Bitv.length v1 - 1 do
    if i mod 2 = 0 then Bitv.set v1 i true
  done;
  Bitv.bw_and_in_place ~dst:v0 v0 v1;
  print_dyn (v0 |> Bitv.to_dyn);
  [%expect {| "1010101010" |}];
  print_dyn (v1 |> Bitv.to_dyn);
  [%expect {| "1010101010" |}];
  Bitv.fill v1 0 (Bitv.length v1) false;
  for i = 0 to Bitv.length v1 - 1 do
    if i mod 3 = 0 then Bitv.set v1 i true
  done;
  Bitv.bw_and_in_place ~dst:v0 v0 v1;
  print_dyn (v0 |> Bitv.to_dyn);
  [%expect {| "1000001000" |}];
  print_dyn (v1 |> Bitv.to_dyn);
  [%expect {| "1001001001" |}];
  let v_small = Bitv.create 5 true in
  require_does_raise (fun () -> Bitv.bw_and_in_place ~dst:v0 v0 v_small);
  [%expect {| Invalid_argument("Bitv.bw_and_in_place") |}];
  ()
;;
