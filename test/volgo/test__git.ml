(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* [Vcs.Git] *)

let%expect_test "exit0" =
  let test output =
    match Vcs.Git.exit0 output with
    | () -> print_dyn (Dyn.Variant ("Ok", []))
    | exception Err.E err ->
      print_dyn (Dyn.Variant ("Raised", [ Dyn.string (err |> Err.to_string_hum) ]))
  in
  test { exit_code = 0; stdout = ""; stderr = "" };
  [%expect {| Ok |}];
  (* The error does not contain the stdout or stderr, as this is already handled
     by the code that interprets the result of the user function supplied to
     [Vcs.git]. *)
  test { exit_code = 1; stdout = "stdout"; stderr = "stderr" };
  [%expect {| Raised "\"Expected exit code 0.\"" |}];
  ()
;;

let%expect_test "exit0_and_stdout" =
  let test output =
    match Vcs.Git.exit0_and_stdout output with
    | stdout -> print_dyn (stdout |> Dyn.string)
    | exception Err.E err ->
      print_dyn (Dyn.Variant ("Raised", [ Dyn.string (err |> Err.to_string_hum) ]))
  in
  test { exit_code = 0; stdout = "stdout"; stderr = "" };
  [%expect {| "stdout" |}];
  (* Same remark as in [exit0] regarding the error trace. *)
  test { exit_code = 1; stdout = "stdout"; stderr = "stderr" };
  [%expect {| Raised "\"Expected exit code 0.\"" |}];
  ()
;;

let%expect_test "exit_code" =
  let test output =
    match Vcs.Git.exit_code output ~accept:[ 0, "ok"; 42, "other" ] with
    | result -> print_dyn (Dyn.Variant ("Ok", [ result |> Dyn.string ]))
    | exception Err.E err ->
      print_dyn (Dyn.Variant ("Raised", [ Dyn.string (err |> Err.to_string_hum) ]))
  in
  test { exit_code = 0; stdout = ""; stderr = "" };
  [%expect {| Ok "ok" |}];
  test { exit_code = 42; stdout = ""; stderr = "" };
  [%expect {| Ok "other" |}];
  (* Same remark as in [exit0] regarding the error trace. *)
  test { exit_code = 1; stdout = ""; stderr = "" };
  [%expect {| Raised "(\"Unexpected exit code.\" (accepted_codes (0 42)))" |}];
  ()
;;

(* [Vcs.Git.Result] *)

let%expect_test "exit0" =
  let test output =
    print_s (Vcs.Git.Result.exit0 output |> Vcs.Result.sexp_of_t (fun () -> Sexp.List []))
  in
  test { exit_code = 0; stdout = ""; stderr = "" };
  [%expect {| (Ok ()) |}];
  (* The error does not contain the stdout or stderr, as this is already handled
     by the code that interprets the result of the user function supplied to
     [Vcs.Result.git]. *)
  test { exit_code = 1; stdout = "stdout"; stderr = "stderr" };
  [%expect {| (Error "Expected exit code 0.") |}];
  ()
;;

let%expect_test "exit0_and_stdout" =
  let test output =
    print_s
      (Vcs.Git.Result.exit0_and_stdout output |> Vcs.Result.sexp_of_t String.sexp_of_t)
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
      (Vcs.Git.Result.exit_code output ~accept:[ 0, "ok"; 42, "other" ]
       |> Vcs.Result.sexp_of_t String.sexp_of_t)
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
