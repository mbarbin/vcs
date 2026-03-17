(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "List.count" =
  let test li ~f = print_dyn (List.count li ~f |> Dyn.int) in
  test [ 0; 1; 2 ] ~f:(fun i -> i mod 2 = 0);
  [%expect {| 2 |}];
  ()
;;
