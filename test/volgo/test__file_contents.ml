(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "create" =
  (* There's nothing particular to test, file contents is simply a wrapper. *)
  let c = Vcs.File_contents.create "raw contents\nof file\n" in
  require_equal (module String) (Vcs.File_contents.to_string c) (c :> string);
  [%expect {||}];
  print_string (c :> string);
  [%expect
    {|
    raw contents
    of file |}];
  ()
;;
