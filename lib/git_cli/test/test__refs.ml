(*******************************************************************************)
(*  Vcs - a versatile OCaml library for Git interaction                        *)
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

(* [super-master-mind.refs] has been created by capturing the output of:

   {v
      $ git show-refs
   v}

   In this test we verify that we can parse this output, and compute a few things
   from it.

   For a more comprehensive test, see [test_vcs_tree.ml]. *)

let%expect_test "parse_exn" =
  Eio_main.run
  @@ fun env ->
  let path = Eio.Path.(Eio.Stdenv.fs env / "super-master-mind.refs") in
  let contents = Eio.Path.load path in
  let lines = String.split_lines contents in
  let refs = Git_cli.Refs.parse_lines_exn ~lines in
  print_s
    [%sexp
      { tags = (Vcs.Refs.tags refs : Set.M(Vcs.Tag_name).t)
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
