(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024 Mathieu Barbin <mathieu.barbin@gmail.com>               *)
(*                                                                             *)
(*  This file is part of Vcs.                                                  *)
(*                                                                             *)
(*  Vcs is free software; you can redistribute it and/or modify it under       *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Vcs is distributed in the hope that it will be useful, but WITHOUT ANY     *)
(*  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*  the file `NOTICE.md` at the root of this repository for more details.      *)
(*                                                                             *)
(*  You should have received a copy of the GNU Lesser General Public License   *)
(*  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*******************************************************************************)

(* [Vcs.Git] *)

let%expect_test "exit0" =
  let test output =
    match Vcs.Git.exit0 output with
    | () -> print_s [%sexp Ok ()]
    | exception Vcs.E err -> print_s [%sexp Raised (err : Vcs.Err.t)]
  in
  test { exit_code = 0; stdout = ""; stderr = "" };
  [%expect {| (Ok ()) |}];
  (* The error does not contain the stdout or stderr, as this is already handled
     by the code that interprets the result of the user function supplied to
     [Vcs.git]. *)
  test { exit_code = 1; stdout = "stdout"; stderr = "stderr" };
  [%expect {| (Raised "expected exit code 0") |}];
  ()
;;

let%expect_test "exit0_and_stdout" =
  let test output =
    match Vcs.Git.exit0_and_stdout output with
    | stdout -> print_s [%sexp (stdout : string)]
    | exception Vcs.E err -> print_s [%sexp Raised (err : Vcs.Err.t)]
  in
  test { exit_code = 0; stdout = "stdout"; stderr = "" };
  [%expect {| stdout |}];
  (* Same remark as in [exit0] regarding the error trace. *)
  test { exit_code = 1; stdout = "stdout"; stderr = "stderr" };
  [%expect {| (Raised "expected exit code 0") |}];
  ()
;;

let%expect_test "exit_code" =
  let test output =
    match Vcs.Git.exit_code output ~accept:[ 0, "ok"; 42, "other" ] with
    | result -> print_s [%sexp Ok (result : string)]
    | exception Vcs.E err -> print_s [%sexp Raised (err : Vcs.Err.t)]
  in
  test { exit_code = 0; stdout = ""; stderr = "" };
  [%expect {| (Ok ok) |}];
  test { exit_code = 42; stdout = ""; stderr = "" };
  [%expect {| (Ok other) |}];
  (* Same remark as in [exit0] regarding the error trace. *)
  test { exit_code = 1; stdout = ""; stderr = "" };
  [%expect {| (Raised ("unexpected exit code" ((accepted_codes (0 42))))) |}];
  ()
;;

(* [Vcs.Git.Or_error] *)

let%expect_test "exit0" =
  let test output = print_s [%sexp (Vcs.Git.Or_error.exit0 output : unit Or_error.t)] in
  test { exit_code = 0; stdout = ""; stderr = "" };
  [%expect {| (Ok ()) |}];
  (* The error does not contain the stdout or stderr, as this is already handled
     by the code that interprets the result of the user function supplied to
     [Vcs.Or_error.git]. *)
  test { exit_code = 1; stdout = "stdout"; stderr = "stderr" };
  [%expect {| (Error "expected exit code 0") |}];
  ()
;;

let%expect_test "exit0_and_stdout" =
  let test output =
    print_s [%sexp (Vcs.Git.Or_error.exit0_and_stdout output : string Or_error.t)]
  in
  test { exit_code = 0; stdout = "stdout"; stderr = "" };
  [%expect {| (Ok stdout) |}];
  (* Same remark as in [exit0] regarding the error trace. *)
  test { exit_code = 1; stdout = "stdout"; stderr = "stderr" };
  [%expect {| (Error "expected exit code 0") |}];
  ()
;;

let%expect_test "exit_code" =
  let test output =
    print_s
      [%sexp
        (Vcs.Git.Or_error.exit_code output ~accept:[ 0, "ok"; 42, "other" ]
         : string Or_error.t)]
  in
  test { exit_code = 0; stdout = ""; stderr = "" };
  [%expect {| (Ok ok) |}];
  test { exit_code = 42; stdout = ""; stderr = "" };
  [%expect {| (Ok other) |}];
  (* Same remark as in [exit0] regarding the error trace. *)
  test { exit_code = 1; stdout = ""; stderr = "" };
  [%expect {| (Error ("unexpected exit code" ((accepted_codes (0 42))))) |}];
  ()
;;

(* [Vcs.Git.Result] *)

let%expect_test "exit0" =
  let test output =
    match Vcs.Git.Result.exit0 output with
    | Ok () -> print_s [%sexp Ok]
    | Error (`Vcs err) -> print_s [%sexp Error (err : Vcs.Err.t)]
  in
  test { exit_code = 0; stdout = ""; stderr = "" };
  [%expect {| Ok |}];
  (* The error does not contain the stdout or stderr, as this is already handled
     by the code that interprets the result of the user function supplied to
     [Vcs.Result.git]. *)
  test { exit_code = 1; stdout = "stdout"; stderr = "stderr" };
  [%expect {| (Error "expected exit code 0") |}];
  ()
;;

let%expect_test "exit0_and_stdout" =
  let test output =
    match Vcs.Git.Result.exit0_and_stdout output with
    | Ok stdout -> print_s [%sexp Ok (stdout : string)]
    | Error (`Vcs err) -> print_s [%sexp Error (err : Vcs.Err.t)]
  in
  test { exit_code = 0; stdout = "stdout"; stderr = "" };
  [%expect {| (Ok stdout) |}];
  (* Same remark as in [exit0] regarding the error trace. *)
  test { exit_code = 1; stdout = "stdout"; stderr = "stderr" };
  [%expect {| (Error "expected exit code 0") |}];
  ()
;;

let%expect_test "exit_code" =
  let test output =
    match Vcs.Git.Result.exit_code output ~accept:[ 0, "ok"; 42, "other" ] with
    | Ok result -> print_s [%sexp Ok (result : string)]
    | Error (`Vcs err) -> print_s [%sexp Error (err : Vcs.Err.t)]
  in
  test { exit_code = 0; stdout = ""; stderr = "" };
  [%expect {| (Ok ok) |}];
  test { exit_code = 42; stdout = ""; stderr = "" };
  [%expect {| (Ok other) |}];
  (* Same remark as in [exit0] regarding the error trace. *)
  test { exit_code = 1; stdout = ""; stderr = "" };
  [%expect {| (Error ("unexpected exit code" ((accepted_codes (0 42))))) |}];
  ()
;;
