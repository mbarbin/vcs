(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

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
