(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "of_string" =
  let test str =
    match Vcs.Remote_branch_name.of_string str with
    | Ok a -> print_endline (Vcs.Remote_branch_name.to_string a)
    | Error (`Msg m) -> print_dyn (Dyn.Variant ("Error", [ Dyn.string m ]))
  in
  test "no space";
  [%expect {| Error "\"no space\": invalid remote_branch_name" |}];
  test "slashes/are/allowed";
  [%expect {| slashes/are/allowed |}];
  test "origin/main";
  [%expect {| origin/main |}];
  test "origin/dashes-and_underscores";
  [%expect {| origin/dashes-and_underscores |}];
  test "local-branch";
  [%expect {| Error "\"local-branch\": invalid remote_branch_name" |}];
  (* Some characters are currently not accepted. *)
  test "\\";
  [%expect {| Error "\"\\\\\": invalid remote_branch_name" |}];
  (* And we do not accept the empty string. *)
  test "";
  [%expect {| Error "\"\": invalid remote_branch_name" |}];
  ()
;;
