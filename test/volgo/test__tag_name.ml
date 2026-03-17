(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "of_string" =
  let test str =
    match Vcs.Tag_name.of_string str with
    | Ok a -> print_endline (Vcs.Tag_name.to_string a)
    | Error (`Msg m) -> print_dyn (Dyn.Variant ("Error", [ Dyn.string m ]))
  in
  test "no space";
  [%expect {| Error "\"no space\": invalid tag_name" |}];
  test "slashes/are/allowed";
  [%expect {| slashes/are/allowed |}];
  test "dashes-and_underscores";
  [%expect {| dashes-and_underscores |}];
  test "with@at";
  [%expect {| with@at |}];
  test "with#hash";
  [%expect {| with#hash |}];
  test "predicate@0.1.0";
  [%expect {| predicate@0.1.0 |}];
  test "0.1.8";
  [%expect {| 0.1.8 |}];
  test "v0.1.8";
  [%expect {| v0.1.8 |}];
  test "1.0.0-beta+exp.sha.5114f85";
  [%expect {| 1.0.0-beta+exp.sha.5114f85 |}];
  (* Some characters are currently not accepted. *)
  test "\\";
  [%expect {| Error "\"\\\\\": invalid tag_name" |}];
  (* And we do not accept the empty string. *)
  test "";
  [%expect {| Error "\"\": invalid tag_name" |}];
  ()
;;

let%expect_test "no ~" =
  (* At one point we were tempted to allow '~' as a valid tag character, since
     it is used as part of preview version names such as [0.1.0~preview].
     However, this is rejected by git itself so we shouldn't allow it. *)
  require_does_raise (fun () -> Vcs.Tag_name.v "1.4.5~preview-0.1");
  [%expect {| Invalid_argument("\"1.4.5~preview-0.1\": invalid tag_name") |}]
;;
