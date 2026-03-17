(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Vcs = Volgo_base.Vcs

let%expect_test "sexp_of_t" =
  let test r = print_s (r |> Vcs.Or_error.sexp_of_t Int.sexp_of_t) in
  test (Or_error.error_s (Dyn.to_sexp (Dyn.variant "Hello" [])));
  [%expect {| (Error Hello) |}];
  test (Or_error.return 0);
  [%expect {| (Ok 0) |}];
  ()
;;
