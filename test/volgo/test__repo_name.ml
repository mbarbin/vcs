(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "of_string" =
  let test str =
    match Vcs.Repo_name.of_string str with
    | Ok a -> print_endline (Vcs.Repo_name.to_string a)
    | Error (`Msg m) -> print_dyn (Dyn.Variant ("Error", [ Dyn.string m ]))
  in
  test "no space";
  [%expect {| Error "\"no space\": invalid repo_name" |}];
  test "slashes/are/not/allowed";
  [%expect {| Error "\"slashes/are/not/allowed\": invalid repo_name" |}];
  test "dashes-and_underscores";
  [%expect {| dashes-and_underscores |}];
  (* Some characters are currently not accepted. *)
  test "\\";
  [%expect {| Error "\"\\\\\": invalid repo_name" |}];
  (* And we do not accept the empty string. *)
  test "";
  [%expect {| Error "\"\": invalid repo_name" |}];
  ()
;;
