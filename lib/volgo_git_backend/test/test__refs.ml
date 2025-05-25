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

(* [super-master-mind.refs] has been created by capturing the output of:

   {v
      $ git show-refs
   v}

   In this test we verify that we can parse this output. *)

let%expect_test "parse_exn" =
  Eio_main.run
  @@ fun env ->
  let path = Eio.Path.(Eio.Stdenv.fs env / "super-master-mind.refs") in
  let contents = Eio.Path.load path in
  let lines = String.split_lines contents in
  let refs = Volgo_git_backend.Refs.parse_lines_exn ~lines in
  print_s
    [%sexp
      { tags = (Vcs.Refs.tags refs : Vcs.Tag_name.t list)
      ; local_branches = (Vcs.Refs.local_branches refs : Vcs.Branch_name.t list)
      ; remote_branches = (Vcs.Refs.remote_branches refs : Vcs.Remote_branch_name.t list)
      }];
  [%expect
    {|
     ((tags (0.0.1 0.0.2 0.0.3 0.0.3-preview.1))
      (local_branches (gh-pages main subrepo))
      (remote_branches (
        ((remote_name origin) (branch_name 0.0.3-preview))
        ((remote_name origin) (branch_name gh-pages))
        ((remote_name origin) (branch_name main))
        ((remote_name origin) (branch_name progress-bar))
        ((remote_name origin) (branch_name progress-bar.2))))) |}];
  ()
;;

let%expect_test "parse_ref_kind_exn" =
  let test_ref_kind str =
    print_s [%sexp (Volgo_git_backend.Refs.parse_ref_kind_exn str : Vcs.Ref_kind.t)]
  in
  require_does_raise [%here] (fun () -> test_ref_kind "blah");
  [%expect
    {|
    ((context (Volgo_git_backend.Refs.parse_ref_kind_exn ((ref_kind blah))))
     (error "Expected ref to start with ['refs/']."))
    |}];
  require_does_raise [%here] (fun () -> test_ref_kind "non-refs/tags/0.0.1");
  [%expect
    {|
    ((context (
       Volgo_git_backend.Refs.parse_ref_kind_exn ((ref_kind non-refs/tags/0.0.1))))
     (error "Expected ref to start with ['refs/']."))
    |}];
  test_ref_kind "refs/blah";
  [%expect {| (Other (name blah)) |}];
  test_ref_kind "refs/blah/blah";
  [%expect {| (Other (name blah/blah)) |}];
  test_ref_kind "refs/heads/blah";
  [%expect {| (Local_branch (branch_name blah)) |}];
  require_does_raise [%here] (fun () -> test_ref_kind "refs/remotes/blah");
  [%expect
    {|
    ((context (
       Volgo_git_backend.Refs.parse_ref_kind_exn ((ref_kind refs/remotes/blah))))
     (error (Invalid_argument "\"blah\": invalid remote_branch_name")))
    |}];
  test_ref_kind "refs/remotes/origin/main";
  [%expect
    {|
    (Remote_branch (
      remote_branch_name (
        (remote_name origin)
        (branch_name main)))) |}];
  test_ref_kind "refs/tags/0.0.1";
  [%expect {| (Tag (tag_name 0.0.1)) |}];
  ()
;;

let%expect_test "dereferenced" =
  let test line =
    print_s
      [%sexp
        (Volgo_git_backend.Refs.Dereferenced.parse_exn ~line
         : Volgo_git_backend.Refs.Dereferenced.t)]
  in
  require_does_raise [%here] (fun () -> test "");
  [%expect
    {|
    ((context (Volgo_git_backend.Refs.Dereferenced.parse_exn ((line ""))))
     (error "Invalid ref line."))
    |}];
  test "1185512b92d612b25613f2e5b473e5231185512b refs/heads/main";
  [%expect
    {|
    ((rev 1185512b92d612b25613f2e5b473e5231185512b)
     (ref_kind (Local_branch (branch_name main)))
     (dereferenced false)) |}];
  test "1185512b92d612b25613f2e5b473e5231185512b refs/heads/main^{}";
  [%expect
    {|
    ((rev 1185512b92d612b25613f2e5b473e5231185512b)
     (ref_kind (Local_branch (branch_name main)))
     (dereferenced true)) |}];
  ()
;;
