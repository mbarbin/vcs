(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Vcs = Volgo_base.Vcs

let%expect_test "to_error" =
  let test err = print_s (Vcs.Err.to_error err |> Error.sexp_of_t) in
  test (Err.create [ Pp.text "Hello" ]);
  [%expect {| Hello |}];
  test
    (Err.add_context
       (Err.create [ Err.sexp (Dyn.to_sexp (Dyn.variant "Hello" [])) ])
       [ Err.sexp (Dyn.to_sexp (Dyn.variant "Step" [])) ]);
  [%expect {| ((context Step) (error Hello)) |}];
  test (Err.create [ Pp.text "Hello"; Err.sexp (Dyn.to_sexp (Dyn.variant "Step" [])) ]);
  [%expect {| (Hello Step) |}];
  ()
;;

let%expect_test "of_error" =
  let test err = print_s (Vcs.Err.of_error err |> Err.sexp_of_t) in
  test (Error.create_s (Dyn.to_sexp (Dyn.variant "Hello" [])));
  [%expect {| Hello |}];
  ()
;;
