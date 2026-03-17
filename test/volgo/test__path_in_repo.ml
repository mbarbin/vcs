(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "of_string" =
  let test s =
    match Vcs.Path_in_repo.of_string s with
    | Ok a -> print_endline (Vcs.Path_in_repo.to_string a)
    | Error (`Msg m) -> print_dyn (Dyn.Variant ("Error", [ Dyn.string m ]))
  in
  test "";
  [%expect {| Error "\"\": invalid path" |}];
  test ".";
  [%expect {| ./ |}];
  test "/";
  [%expect {| Error "\"/\" is not a relative path" |}];
  test "/a/foo";
  [%expect {| Error "\"/a/foo\" is not a relative path" |}];
  test "a/foo/bar";
  [%expect {| a/foo/bar |}];
  (* We do keep the trailing slashes if present syntactically. Although we do
     not expect such paths to be computed by the [Vcs] library from files
     present in the repo. *)
  test "a/foo/bar/";
  [%expect {| a/foo/bar/ |}];
  test "file";
  [%expect {| file |}];
  test "a/foo/bar/../sna";
  [%expect {| a/foo/sna |}];
  ()
;;
