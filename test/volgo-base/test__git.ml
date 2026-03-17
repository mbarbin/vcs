(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Vcs = Volgo_base.Vcs

let%expect_test "exit0" =
  let test output =
    print_s (Vcs.Git.Or_error.exit0 output |> Or_error.sexp_of_t (fun () -> Sexp.List []))
  in
  test { exit_code = 0; stdout = ""; stderr = "" };
  [%expect {| (Ok ()) |}];
  (* The error does not contain the stdout or stderr, as this is already handled
     by the code that interprets the result of the user function supplied to
     [Vcs.Or_error.git]. *)
  test { exit_code = 1; stdout = "stdout"; stderr = "stderr" };
  [%expect {| (Error "Expected exit code 0.") |}];
  ()
;;

let%expect_test "exit0_and_stdout" =
  let test output =
    print_s
      (Vcs.Git.Or_error.exit0_and_stdout output |> Or_error.sexp_of_t String.sexp_of_t)
  in
  test { exit_code = 0; stdout = "stdout"; stderr = "" };
  [%expect {| (Ok stdout) |}];
  (* Same remark as in [exit0] regarding the error trace. *)
  test { exit_code = 1; stdout = "stdout"; stderr = "stderr" };
  [%expect {| (Error "Expected exit code 0.") |}];
  ()
;;

let%expect_test "exit_code" =
  let test output =
    print_s
      (Vcs.Git.Or_error.exit_code output ~accept:[ 0, "ok"; 42, "other" ]
       |> Or_error.sexp_of_t String.sexp_of_t)
  in
  test { exit_code = 0; stdout = ""; stderr = "" };
  [%expect {| (Ok ok) |}];
  test { exit_code = 42; stdout = ""; stderr = "" };
  [%expect {| (Ok other) |}];
  (* Same remark as in [exit0] regarding the error trace. *)
  test { exit_code = 1; stdout = ""; stderr = "" };
  [%expect {| (Error ("Unexpected exit code." (accepted_codes (0 42)))) |}];
  ()
;;
