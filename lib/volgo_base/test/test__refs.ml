(*******************************************************************************)
(*  Volgo - a Versatile OCaml Library for Git Operations                       *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
(*                                                                             *)
(*  This file is part of Volgo.                                                *)
(*                                                                             *)
(*  Volgo is free software; you can redistribute it and/or modify it under     *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Volgo is distributed in the hope that it will be useful, but WITHOUT ANY   *)
(*  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*  the file `NOTICE.md` at the root of this repository for more details.      *)
(*                                                                             *)
(*  You should have received a copy of the GNU Lesser General Public License   *)
(*  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*******************************************************************************)

module Vcs = Volgo_base.Vcs

let%expect_test "parse_exn" =
  Eio_main.run
  @@ fun env ->
  let path = Eio.Path.(Eio.Stdenv.fs env / "super-master-mind.refs") in
  let contents = Eio.Path.load path in
  let lines = String.split_lines contents in
  let refs = Volgo_git_backend.Refs.parse_lines_exn ~lines in
  print_s
    [%sexp
      { tags = (Vcs.Refs.tags refs : Set.M(Vcs.Tag_name).t)
      ; local_branches = (Vcs.Refs.local_branches refs : Set.M(Vcs.Branch_name).t)
      ; remote_branches =
          (Vcs.Refs.remote_branches refs : Set.M(Vcs.Remote_branch_name).t)
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
  print_s [%sexp (Vcs.Refs.to_map refs : Vcs.Rev.t Map.M(Vcs.Ref_kind).t)];
  [%expect
    {|
    (((Local_branch (branch_name gh-pages))
      7135b7f4790562e94d9122365478f0d39f5ffead)
     ((Local_branch (branch_name main)) 2e4fbeae154ec896262decf1ab3bee5687b93f21)
     ((Local_branch (branch_name subrepo))
      2e4fbeae154ec896262decf1ab3bee5687b93f21)
     ((Remote_branch (
        remote_branch_name (
          (remote_name origin)
          (branch_name 0.0.3-preview))))
      8e0e6821261f8baaff7bf4d6820c41417bab91eb)
     ((Remote_branch (
        remote_branch_name (
          (remote_name origin)
          (branch_name gh-pages))))
      7135b7f4790562e94d9122365478f0d39f5ffead)
     ((Remote_branch (
        remote_branch_name (
          (remote_name origin)
          (branch_name main))))
      2e4fbeae154ec896262decf1ab3bee5687b93f21)
     ((Remote_branch (
        remote_branch_name (
          (remote_name origin)
          (branch_name progress-bar))))
      a2cc521adbc8dcbd4855968698176e8af54f6550)
     ((Remote_branch (
        remote_branch_name (
          (remote_name origin)
          (branch_name progress-bar.2))))
      7500919364fb176946e7598051ca7247addc3d15)
     ((Tag (tag_name 0.0.1)) 1892d4980ee74945eb98f67be26b745f96c0f482)
     ((Tag (tag_name 0.0.2)) 0d4750ff594236a4bd970e1c90b8bbad80fcadff)
     ((Tag (tag_name 0.0.3)) fc8e67fbc47302b7da682e9a7da626790bb59eaa)
     ((Tag (tag_name 0.0.3-preview.1)) 1887c81ebf9b84c548bc35038f7af82a18eb77bf))
    |}];
  ()
;;
