(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "show" =
  let test output =
    print_s
      (Volgo_git_backend.Show.interpret_output output
       |> Vcs.Result.sexp_of_t Vcs.File_shown_at_rev.sexp_of_t)
  in
  test { exit_code = 0; stdout = "contents"; stderr = "" };
  [%expect {| (Ok (Present contents)) |}];
  test { exit_code = 128; stdout = "contents"; stderr = "" };
  [%expect {| (Ok Absent) |}];
  test { exit_code = 1; stdout = "contents"; stderr = "" };
  [%expect {| (Error ("Unexpected exit code." (accepted_codes (0 128)))) |}];
  ()
;;
