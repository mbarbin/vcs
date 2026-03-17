(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "to_string" =
  let test t = print_endline (Vcs.Ref_kind.to_string t) in
  test (Local_branch { branch_name = Vcs.Branch_name.main });
  [%expect {| refs/heads/main |}];
  test (Remote_branch { remote_branch_name = Vcs.Remote_branch_name.v "origin/main" });
  [%expect {| refs/remotes/origin/main |}];
  test (Tag { tag_name = Vcs.Tag_name.v "0.1.3" });
  [%expect {| refs/tags/0.1.3 |}];
  test (Other { name = "name" });
  [%expect {| refs/name |}];
  ()
;;
