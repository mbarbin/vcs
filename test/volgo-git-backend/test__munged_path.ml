(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Munged_path = Volgo_git_backend.Private.Munged_path

let%expect_test "parse" =
  let test path = print_dyn (Munged_path.parse_exn path |> Munged_path.to_dyn) in
  require_does_raise (fun () -> test "");
  [%expect
    {|
    ((context (Volgo_git_backend.Munged_path.parse_exn (path "")))
      (error "Unexpected empty path."))
    |}];
  require_does_raise (fun () -> test "/tmp => /tmp");
  [%expect
    {|
    ((context (Volgo_git_backend.Munged_path.parse_exn (path "/tmp => /tmp")))
      (error (Invalid_argument "\"/tmp\" is not a relative path")))
    |}];
  require_does_raise (fun () -> test "tmp => tmp2 => tmp3");
  [%expect
    {|
    ((context
       (Volgo_git_backend.Munged_path.parse_exn (path "tmp => tmp2 => tmp3")))
      (error "Too many ['=>']."))
    |}];
  test "}";
  [%expect {| One_file "}" |}];
  test "{";
  [%expect {| One_file "{" |}];
  test "template/with-with-{{ variable }}.txt";
  [%expect {| One_file "template/with-with-{{ variable }}.txt" |}];
  require_does_raise (fun () -> test "a/{dir => b");
  [%expect
    {|
    ((context (Volgo_git_backend.Munged_path.parse_exn (path "a/{dir => b")))
      (error "Matching '}' not found."))
    |}];
  require_does_raise (fun () -> test "a/dir => b}");
  [%expect
    {|
    ((context (Volgo_git_backend.Munged_path.parse_exn (path "a/dir => b}")))
      (error "Matching '{' not found."))
    |}];
  test "a/simple/path";
  [%expect {| One_file "a/simple/path" |}];
  test "a/simple/path => another/path";
  [%expect {| Two_files { src = "a/simple/path"; dst = "another/path" } |}];
  test "a/{simple => not/so/simple}/path";
  [%expect {| Two_files { src = "a/simple/path"; dst = "a/not/so/simple/path" } |}];
  ()
;;
