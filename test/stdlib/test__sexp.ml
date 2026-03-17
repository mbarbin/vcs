(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "Sexp.to_dyn" =
  let test t = print_dyn (Sexp.to_dyn t) in
  test (Atom "Hello Who?");
  [%expect {| Atom "Hello Who?" |}];
  test (List [ Atom "Hello"; Atom "World!" ]);
  [%expect {| List [ Atom "Hello"; Atom "World!" ] |}];
  ()
;;
