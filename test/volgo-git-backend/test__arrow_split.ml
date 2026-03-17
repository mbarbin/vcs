(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Arrow_split = Volgo_git_backend.Private.Arrow_split

let%expect_test "split" =
  let test str = print_dyn (Arrow_split.to_dyn (Arrow_split.split str)) in
  test "";
  [%expect {| Empty |}];
  test "a/simple/path";
  [%expect {| One "a/simple/path" |}];
  test "a/simple/path => another/path";
  [%expect {| Two ("a/simple/path", "another/path") |}];
  test "tmp => tmp2 => tmp3";
  [%expect {| More_than_two |}];
  ()
;;
