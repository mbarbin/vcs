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

let%expect_test "tree" =
  Eio_main.run
  @@ fun env ->
  let log =
    let path = Eio.Path.(Eio.Stdenv.fs env / "super-master-mind.log") in
    let contents = Eio.Path.load path in
    let lines = String.split_lines contents in
    List.map lines ~f:(fun line -> Git_cli.Log.parse_log_line_exn ~line)
  in
  let refs =
    let path = Eio.Path.(Eio.Stdenv.fs env / "super-master-mind.refs") in
    let contents = Eio.Path.load path in
    let lines = String.split_lines contents in
    Git_cli.Refs.parse_lines_exn ~lines
  in
  let tree = Vcs.Tree.create () in
  Vcs.Tree.add_nodes tree ~log;
  List.iter refs ~f:(fun { rev; ref_kind } -> Vcs.Tree.set_ref tree ~rev ~ref_kind);
  let refs = Vcs.Tree.refs tree in
  List.iter refs ~f:(fun { rev; ref_kind } ->
    let node = Vcs.Tree.find_ref tree ~ref_kind |> Option.value_exn ~here:[%here] in
    let rev' = Vcs.Tree.Node.rev tree node in
    require_equal [%here] (module Vcs.Rev) rev rev';
    let node' = Vcs.Tree.find_rev tree ~rev |> Option.value_exn ~here:[%here] in
    require_equal [%here] (module Vcs.Tree.Node) node node';
    let parents =
      Vcs.Tree.Node.parents tree node |> List.map ~f:(Vcs.Tree.Node.rev tree)
    in
    print_s
      [%sexp { ref_kind : Vcs.Ref_kind.t; rev : Vcs.Rev.t; parents : Vcs.Rev.t list }]);
  [%expect
    {|
    ((ref_kind (Local_branch (branch_name gh-pages)))
     (rev 7135b7f4790562e94d9122365478f0d39f5ffead)
     (parents (ad9e24e4ee719d71b07ce29597818461b38c9e4a)))
    ((ref_kind (Local_branch (branch_name main)))
     (rev 2e4fbeae154ec896262decf1ab3bee5687b93f21)
     (parents (3820ba70563c65ee9f6d516b8e70eb5ea8173d45)))
    ((ref_kind (Local_branch (branch_name subrepo)))
     (rev 2e4fbeae154ec896262decf1ab3bee5687b93f21)
     (parents (3820ba70563c65ee9f6d516b8e70eb5ea8173d45)))
    ((ref_kind (
       Remote_branch (
         remote_branch_name (
           (remote_name origin)
           (branch_name 0.0.3-preview)))))
     (rev 8e0e6821261f8baaff7bf4d6820c41417bab91eb)
     (parents (1887c81ebf9b84c548bc35038f7af82a18eb77bf)))
    ((ref_kind (
       Remote_branch (
         remote_branch_name (
           (remote_name origin)
           (branch_name gh-pages)))))
     (rev 7135b7f4790562e94d9122365478f0d39f5ffead)
     (parents (ad9e24e4ee719d71b07ce29597818461b38c9e4a)))
    ((ref_kind (
       Remote_branch (
         remote_branch_name (
           (remote_name origin)
           (branch_name main)))))
     (rev 2e4fbeae154ec896262decf1ab3bee5687b93f21)
     (parents (3820ba70563c65ee9f6d516b8e70eb5ea8173d45)))
    ((ref_kind (
       Remote_branch (
         remote_branch_name (
           (remote_name origin)
           (branch_name progress-bar)))))
     (rev a2cc521adbc8dcbd4855968698176e8af54f6550)
     (parents (4fbe82806f16bac64c099fa28300efe4a3c7c478)))
    ((ref_kind (
       Remote_branch (
         remote_branch_name (
           (remote_name origin)
           (branch_name progress-bar.2)))))
     (rev 7500919364fb176946e7598051ca7247addc3d15)
     (parents (ad01432770d3f696cf9312a6a45a559e3d2ac814)))
    ((ref_kind (Tag (tag_name 0.0.1)))
     (rev 1892d4980ee74945eb98f67be26b745f96c0f482)
     (parents (728e5a4ebfaa8564358b17fd754dacea9a6b0153)))
    ((ref_kind (Tag (tag_name 0.0.2)))
     (rev 0d4750ff594236a4bd970e1c90b8bbad80fcadff)
     (parents (11c7861ae090e2dc5e2400d4d8a90c74b0a37163)))
    ((ref_kind (Tag (tag_name 0.0.3)))
     (rev fc8e67fbc47302b7da682e9a7da626790bb59eaa)
     (parents (6e463fbe6765015b8427f004f856ee4d77cc9ccd)))
    ((ref_kind (Tag (tag_name 0.0.3-preview.1)))
     (rev 1887c81ebf9b84c548bc35038f7af82a18eb77bf)
     (parents (b258b0cde128083c4f05bcf276bcc1322f1d36a2))) |}];
  print_s [%sexp (Vcs.Tree.summary tree : Vcs.Tree.Summary.t)];
  [%expect
    {|
    ((refs (
       (7135b7f4790562e94d9122365478f0d39f5ffead refs/heads/gh-pages)
       (2e4fbeae154ec896262decf1ab3bee5687b93f21 refs/heads/main)
       (2e4fbeae154ec896262decf1ab3bee5687b93f21 refs/heads/subrepo)
       (8e0e6821261f8baaff7bf4d6820c41417bab91eb
        refs/remotes/origin/0.0.3-preview)
       (7135b7f4790562e94d9122365478f0d39f5ffead refs/remotes/origin/gh-pages)
       (2e4fbeae154ec896262decf1ab3bee5687b93f21 refs/remotes/origin/main)
       (a2cc521adbc8dcbd4855968698176e8af54f6550 refs/remotes/origin/progress-bar)
       (7500919364fb176946e7598051ca7247addc3d15
        refs/remotes/origin/progress-bar.2)
       (1892d4980ee74945eb98f67be26b745f96c0f482 refs/tags/0.0.1)
       (0d4750ff594236a4bd970e1c90b8bbad80fcadff refs/tags/0.0.2)
       (fc8e67fbc47302b7da682e9a7da626790bb59eaa refs/tags/0.0.3)
       (1887c81ebf9b84c548bc35038f7af82a18eb77bf refs/tags/0.0.3-preview.1)))
     (roots (
       da46f0d60bfbb9dc9340e95f5625c10815c24af7
       35760b109070be51b9deb61c8fdc79c0b2d9065d))
     (tips (
       (a2cc521adbc8dcbd4855968698176e8af54f6550 (
         refs/remotes/origin/progress-bar))
       (8e0e6821261f8baaff7bf4d6820c41417bab91eb (
         refs/remotes/origin/0.0.3-preview))
       (7500919364fb176946e7598051ca7247addc3d15 (
         refs/remotes/origin/progress-bar.2))
       (7135b7f4790562e94d9122365478f0d39f5ffead (
         refs/heads/gh-pages refs/remotes/origin/gh-pages))
       (2e4fbeae154ec896262decf1ab3bee5687b93f21 (
         refs/heads/main refs/heads/subrepo refs/remotes/origin/main))))
     (subtrees (
       ((refs (
          (2e4fbeae154ec896262decf1ab3bee5687b93f21 refs/heads/main)
          (2e4fbeae154ec896262decf1ab3bee5687b93f21 refs/heads/subrepo)
          (8e0e6821261f8baaff7bf4d6820c41417bab91eb
           refs/remotes/origin/0.0.3-preview)
          (2e4fbeae154ec896262decf1ab3bee5687b93f21 refs/remotes/origin/main)
          (a2cc521adbc8dcbd4855968698176e8af54f6550
           refs/remotes/origin/progress-bar)
          (7500919364fb176946e7598051ca7247addc3d15
           refs/remotes/origin/progress-bar.2)
          (1892d4980ee74945eb98f67be26b745f96c0f482 refs/tags/0.0.1)
          (0d4750ff594236a4bd970e1c90b8bbad80fcadff refs/tags/0.0.2)
          (fc8e67fbc47302b7da682e9a7da626790bb59eaa refs/tags/0.0.3)
          (1887c81ebf9b84c548bc35038f7af82a18eb77bf refs/tags/0.0.3-preview.1)))
        (roots (da46f0d60bfbb9dc9340e95f5625c10815c24af7))
        (tips (
          (2e4fbeae154ec896262decf1ab3bee5687b93f21 (
            refs/heads/main refs/heads/subrepo refs/remotes/origin/main))
          (7500919364fb176946e7598051ca7247addc3d15 (
            refs/remotes/origin/progress-bar.2))
          (8e0e6821261f8baaff7bf4d6820c41417bab91eb (
            refs/remotes/origin/0.0.3-preview))
          (a2cc521adbc8dcbd4855968698176e8af54f6550 (
            refs/remotes/origin/progress-bar)))))
       ((refs (
          (7135b7f4790562e94d9122365478f0d39f5ffead refs/heads/gh-pages)
          (7135b7f4790562e94d9122365478f0d39f5ffead refs/remotes/origin/gh-pages)))
        (roots (35760b109070be51b9deb61c8fdc79c0b2d9065d))
        (tips ((
          7135b7f4790562e94d9122365478f0d39f5ffead (
            refs/heads/gh-pages refs/remotes/origin/gh-pages)))))))) |}];
  let main =
    Vcs.Tree.find_ref
      tree
      ~ref_kind:(Local_branch { branch_name = Vcs.Branch_name.v "main" })
    |> Option.value_exn ~here:[%here]
  in
  let subrepo =
    Vcs.Tree.find_ref
      tree
      ~ref_kind:(Local_branch { branch_name = Vcs.Branch_name.v "subrepo" })
    |> Option.value_exn ~here:[%here]
  in
  let progress_bar =
    Vcs.Tree.find_ref
      tree
      ~ref_kind:
        (Remote_branch
           { remote_branch_name =
               { remote_name = Vcs.Remote_name.v "origin"
               ; branch_name = Vcs.Branch_name.v "progress-bar"
               }
           })
    |> Option.value_exn ~here:[%here]
  in
  let tag_0_0_1 =
    Vcs.Tree.find_ref tree ~ref_kind:(Tag { tag_name = Vcs.Tag_name.v "0.0.1" })
    |> Option.value_exn ~here:[%here]
  in
  let tag_0_0_2 =
    Vcs.Tree.find_ref tree ~ref_kind:(Tag { tag_name = Vcs.Tag_name.v "0.0.2" })
    |> Option.value_exn ~here:[%here]
  in
  List.iter [ main; subrepo; progress_bar; tag_0_0_1; tag_0_0_2 ] ~f:(fun node ->
    print_s
      [%sexp
        { node = (Vcs.Tree.Node.rev tree node : Vcs.Rev.t)
        ; refs = (Vcs.Tree.Node.refs tree node : Vcs.Ref_kind.t list)
        }]);
  [%expect
    {|
    ((node 2e4fbeae154ec896262decf1ab3bee5687b93f21)
     (refs (
       (Local_branch (branch_name main))
       (Local_branch (branch_name subrepo))
       (Remote_branch (
         remote_branch_name (
           (remote_name origin)
           (branch_name main)))))))
    ((node 2e4fbeae154ec896262decf1ab3bee5687b93f21)
     (refs (
       (Local_branch (branch_name main))
       (Local_branch (branch_name subrepo))
       (Remote_branch (
         remote_branch_name (
           (remote_name origin)
           (branch_name main)))))))
    ((node a2cc521adbc8dcbd4855968698176e8af54f6550)
     (refs ((
       Remote_branch (
         remote_branch_name (
           (remote_name origin)
           (branch_name progress-bar)))))))
    ((node 1892d4980ee74945eb98f67be26b745f96c0f482)
     (refs ((Tag (tag_name 0.0.1)))))
    ((node 0d4750ff594236a4bd970e1c90b8bbad80fcadff)
     (refs ((Tag (tag_name 0.0.2))))) |}];
  let is_ancestor ancestor descendant =
    print_s
      [%sexp
        { is_ancestor_or_equal =
            (Vcs.Tree.is_ancestor_or_equal tree ~ancestor ~descendant : bool)
        ; is_strict_ancestor =
            (Vcs.Tree.is_strict_ancestor tree ~ancestor ~descendant : bool)
        }]
  in
  is_ancestor tag_0_0_1 tag_0_0_2;
  [%expect {|
    ((is_ancestor_or_equal true)
     (is_strict_ancestor   true)) |}];
  is_ancestor tag_0_0_2 tag_0_0_1;
  [%expect {|
    ((is_ancestor_or_equal false)
     (is_strict_ancestor   false)) |}];
  is_ancestor main main;
  [%expect {|
    ((is_ancestor_or_equal true)
     (is_strict_ancestor   false)) |}];
  ()
;;
