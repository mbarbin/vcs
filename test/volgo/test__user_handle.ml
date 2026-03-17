(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "of_string" =
  let test str =
    match Vcs.User_handle.of_string str with
    | Ok a -> print_endline (Vcs.User_handle.to_string a)
    | Error (`Msg m) -> print_dyn (Dyn.Variant ("Error", [ Dyn.string m ]))
  in
  test "no space";
  [%expect {| Error "\"no space\": invalid user_handle" |}];
  test "jdoe";
  [%expect {| jdoe |}];
  test "john-doe";
  [%expect {| john-doe |}];
  test "john_doe";
  [%expect {| john_doe |}];
  (* Some characters are currently not accepted. *)
  test "\\";
  [%expect {| Error "\"\\\\\": invalid user_handle" |}];
  (* And we do not accept the empty string. *)
  test "";
  [%expect {| Error "\"\": invalid user_handle" |}];
  ()
;;
