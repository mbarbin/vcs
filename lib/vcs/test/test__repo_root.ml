(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024 Mathieu Barbin <mathieu.barbin@gmail.com>               *)
(*                                                                             *)
(*  This file is part of Vcs.                                                  *)
(*                                                                             *)
(*  Vcs is free software; you can redistribute it and/or modify it under       *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Vcs is distributed in the hope that it will be useful, but WITHOUT ANY     *)
(*  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*  the file `NOTICE.md` at the root of this repository for more details.      *)
(*                                                                             *)
(*  You should have received a copy of the GNU Lesser General Public License   *)
(*  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*******************************************************************************)

let%expect_test "of_string" =
  let test s =
    print_s
      [%sexp (Vcs.Repo_root.of_string s : (Vcs.Repo_root.t, [ `Msg of string ]) Result.t)]
  in
  test "";
  [%expect {| (Error (Msg "\"\": invalid path")) |}];
  test "/";
  [%expect {| (Ok /) |}];
  test ".";
  [%expect {| (Error (Msg "\".\": not an absolute path")) |}];
  test "foo/bar";
  [%expect {| (Error (Msg "\"foo/bar\": not an absolute path")) |}];
  test "/foo/bar";
  [%expect {| (Ok /foo/bar) |}];
  test "/tmp/my-repo";
  [%expect {| (Ok /tmp/my-repo) |}];
  ()
;;

let%expect_test "v" =
  let test s = print_s [%sexp (Vcs.Repo_root.v s : Vcs.Repo_root.t)] in
  require_does_raise [%here] (fun () -> test "");
  [%expect {| (Invalid_argument "\"\": invalid path") |}];
  require_does_raise [%here] (fun () -> test "foo/bar");
  [%expect {| (Invalid_argument "\"foo/bar\": not an absolute path") |}];
  test "/foo/bar";
  [%expect {| /foo/bar |}];
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
    | None -> print_s [%sexp Error "not a prefix"]
  in
  test "/not/in/the/repo";
  [%expect {| (Error "not a prefix") |}];
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
