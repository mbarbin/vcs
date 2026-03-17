(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "of_string" =
  let test str =
    match Vcs.Commit_message.of_string str with
    | Ok a -> print_endline (Vcs.Commit_message.to_string a)
    | Error (`Msg m) -> print_dyn (Dyn.Variant ("Error", [ Dyn.string m ]))
  in
  (* We do not accept the empty string. *)
  test "";
  [%expect {| Error "\"\": invalid commit_message" |}];
  (* Currently all characters are currently accepted. *)
  test "\\ including _ spaces and \n newlines";
  [%expect
    {|
    \ including _ spaces and
     newlines |}];
  (* However we reject entries that are too long. The limit may change later, TBD. *)
  test (String.make 10000 'a');
  [%expect
    {|
    Error
      "\"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa... (10000 characters total)\": invalid commit_message"
    |}];
  ()
;;
