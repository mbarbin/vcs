(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "of_string" =
  let test s =
    match Vcs.Repo_root.of_string s with
    | Ok a -> print_endline (Vcs.Repo_root.to_string a)
    | Error (`Msg m) -> print_dyn (Dyn.Variant ("Error", [ Dyn.string m ]))
  in
  test "";
  [%expect {| Error "\"\": invalid path" |}];
  test "/";
  [%expect {| / |}];
  test ".";
  [%expect {| Error "\".\" is not an absolute path" |}];
  test "foo/bar";
  [%expect {| Error "\"foo/bar\" is not an absolute path" |}];
  test "/foo/bar";
  [%expect {| /foo/bar |}];
  test "/tmp/my-repo";
  [%expect {| /tmp/my-repo |}];
  ()
;;

let%expect_test "v" =
  let test s = print_dyn (Vcs.Repo_root.v s |> Vcs.Repo_root.to_dyn) in
  require_does_raise (fun () -> test "");
  [%expect {| Invalid_argument("\"\": invalid path") |}];
  require_does_raise (fun () -> test "foo/bar");
  [%expect {| Invalid_argument("\"foo/bar\" is not an absolute path") |}];
  test "/foo/bar";
  [%expect {| "/foo/bar" |}];
  ()
;;

let%expect_test "to_string" =
  let test s = print_endline (Vcs.Repo_root.to_string (Vcs.Repo_root.v s)) in
  test "/path/to/repo";
  [%expect {| /path/to/repo |}];
  ()
;;

let%expect_test "relativize_exn" =
  let repo_root = Vcs.Repo_root.v "/tmp/my-repo" in
  let test abs =
    match Vcs.Repo_root.relativize repo_root (Absolute_path.v abs) with
    | Some p -> print_endline (Vcs.Path_in_repo.to_string p)
    | None -> print_dyn (Dyn.Variant ("Error", [ Dyn.string "not a prefix" ]))
  in
  test "/not/in/the/repo";
  [%expect {| Error "not a prefix" |}];
  test "/tmp/my-repo";
  [%expect {| ./ |}];
  test "/tmp/my-repo/";
  [%expect {| ./ |}];
  test "/tmp/my-repo/foo";
  [%expect {| foo |}];
  test "/tmp/my-repo/.foo";
  [%expect {| .foo |}];
  test "/tmp/my-repo/.foo/bar";
  [%expect {| .foo/bar |}];
  test "/tmp/my-repo/foo/bar/../snafu";
  [%expect {| foo/snafu |}];
  ()
;;

let%expect_test "append" =
  let repo_root = Vcs.Repo_root.v "/tmp/my-repo" in
  let test abs =
    print_endline
      (Absolute_path.to_string (Vcs.Repo_root.append repo_root (Vcs.Path_in_repo.v abs)))
  in
  test ".";
  [%expect {| /tmp/my-repo/ |}];
  test ".foo";
  [%expect {| /tmp/my-repo/.foo |}];
  test "foo/bar/../sna";
  [%expect {| /tmp/my-repo/foo/sna |}];
  ()
;;
