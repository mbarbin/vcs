(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
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

module Munged_path = Vcs_git_backend.Private.Munged_path

let%expect_test "parse" =
  let test path = print_s [%sexp (Munged_path.parse_exn path : Munged_path.t)] in
  require_does_raise [%here] (fun () -> test "");
  [%expect
    {|
    (Vcs.E (
      (context (Vcs_git_backend.Munged_path.parse_exn ((path ""))))
      (error "Unexpected empty path.")))
    |}];
  require_does_raise [%here] (fun () -> test "/tmp => /tmp");
  [%expect
    {|
    (Vcs.E (
      (context (Vcs_git_backend.Munged_path.parse_exn ((path "/tmp => /tmp"))))
      (error (Invalid_argument "\"/tmp\": not a relative path"))))
    |}];
  require_does_raise [%here] (fun () -> test "tmp => tmp2 => tmp3");
  [%expect
    {|
    (Vcs.E (
      (context (
        Vcs_git_backend.Munged_path.parse_exn ((path "tmp => tmp2 => tmp3"))))
      (error "Too many ['=>'].")))
    |}];
  require_does_raise [%here] (fun () -> test "}");
  [%expect
    {|
    (Vcs.E (
      (context (Vcs_git_backend.Munged_path.parse_exn ((path }))))
      (error "Unexpected '{' or '}' in simple path.")))
    |}];
  require_does_raise [%here] (fun () -> test "{");
  [%expect
    {|
    (Vcs.E (
      (context (Vcs_git_backend.Munged_path.parse_exn ((path {))))
      (error "Unexpected '{' or '}' in simple path.")))
    |}];
  require_does_raise [%here] (fun () -> test "a/{dir => b");
  [%expect
    {|
    (Vcs.E (
      (context (Vcs_git_backend.Munged_path.parse_exn ((path "a/{dir => b"))))
      (error "Matching '}' not found.")))
    |}];
  require_does_raise [%here] (fun () -> test "a/dir => b}");
  [%expect
    {|
    (Vcs.E (
      (context (Vcs_git_backend.Munged_path.parse_exn ((path "a/dir => b}"))))
      (error "Matching '{' not found.")))
    |}];
  test "a/simple/path";
  [%expect {| (One_file a/simple/path) |}];
  test "a/simple/path => another/path";
  [%expect
    {|
    (Two_files
      (src a/simple/path)
      (dst another/path)) |}];
  test "a/{simple => not/so/simple}/path";
  [%expect
    {|
    (Two_files
      (src a/simple/path)
      (dst a/not/so/simple/path)) |}];
  ()
;;
