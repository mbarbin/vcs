(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "of_string" =
  let test str =
    match Vcs.Author.of_string str with
    | Ok a -> print_endline (Vcs.Author.to_string a)
    | Error (`Msg m) -> print_dyn (Dyn.Variant ("Error", [ Dyn.string m ]))
  in
  test "John Doe";
  [%expect {| John Doe |}];
  test "jdoe";
  [%expect {| jdoe |}];
  test "john-doe";
  [%expect {| john-doe |}];
  test "john_doe";
  [%expect {| john_doe |}];
  (* We currently accept '<,>' chars. *)
  test "John Doe <john.doe@mail.com>";
  [%expect {| John Doe <john.doe@mail.com> |}];
  print_endline
    (Vcs.Author.of_user_config
       ~user_name:("John Doe" |> Vcs.User_name.v)
       ~user_email:("john.doe@mail.com" |> Vcs.User_email.v)
     |> Vcs.Author.to_string);
  [%expect {| John Doe <john.doe@mail.com> |}];
  (* Some characters are currently not accepted. *)
  test "\\";
  [%expect {| Error "\"\\\\\": invalid author" |}];
  (* And we do not accept the empty string. *)
  test "";
  [%expect {| Error "\"\": invalid author" |}];
  ()
;;
