(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Vcs = Volgo_base.Vcs

let%expect_test "to_string_hum" =
  let test t = Stdlib.print_endline (Vcs.Num_lines_in_diff.to_string_hum t) in
  test { insertions = 0; deletions = 0 };
  [%expect {| 0 |}];
  test { insertions = 100; deletions = 0 };
  [%expect {| +100 |}];
  test { insertions = 0; deletions = 15 };
  [%expect {| -15 |}];
  test { insertions = 1999; deletions = 13898 };
  [%expect {| +1_999, -13_898 |}];
  ()
;;
