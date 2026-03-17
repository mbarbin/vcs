(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "Absolute_path.to_dyn" =
  let test t = print_dyn (Absolute_path.to_dyn t) in
  test (Absolute_path.v "/tmp/an/absolute/path");
  [%expect {| "/tmp/an/absolute/path" |}];
  ()
;;

let%expect_test "Relative_path.to_dyn" =
  let test t = print_dyn (Relative_path.to_dyn t) in
  test (Relative_path.v "a/relative/path");
  [%expect {| "a/relative/path" |}];
  ()
;;
