(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "of_string" =
  let test str =
    match Vcs.Rev.of_string str with
    | Ok a -> print_endline (Vcs.Rev.to_string a)
    | Error (`Msg m) -> print_dyn (Dyn.Variant ("Error", [ Dyn.string m ]))
  in
  test "";
  [%expect {| Error "\"\": invalid rev" |}];
  test "too-short";
  [%expect {| Error "\"too-short\": invalid rev" |}];
  test "3a17020189a3e2f321812d06dcd18f173a170201";
  [%expect {| 3a17020189a3e2f321812d06dcd18f173a170201 |}];
  test "3a17020189a3e2f321812d06dcd18f173a170201";
  [%expect {| 3a17020189a3e2f321812d06dcd18f173a170201 |}];
  (* Currently we don't enforce much but the length of the string, and the kind
     of chars that it contains. *)
  test "this-string-is-not-a-rev-but-it-is-valid";
  [%expect {| this-string-is-not-a-rev-but-it-is-valid |}];
  test (String.make 40 ' ');
  [%expect {| Error "\"                                        \": invalid rev" |}];
  ()
;;
