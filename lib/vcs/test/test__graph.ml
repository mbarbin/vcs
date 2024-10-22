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

let%expect_test "graph" =
  Eio_main.run
  @@ fun env ->
  let log =
    let path = Eio.Path.(Eio.Stdenv.fs env / "super-master-mind.log") in
    let contents = Eio.Path.load path in
    let lines = String.split_lines contents in
    List.map lines ~f:(fun line -> Vcs_git_provider.Log.parse_log_line_exn ~line)
  in
  let refs =
    let path = Eio.Path.(Eio.Stdenv.fs env / "super-master-mind.refs") in
    let contents = Eio.Path.load path in
    let lines = String.split_lines contents in
    Vcs_git_provider.Refs.parse_lines_exn ~lines
  in
  let graph = Vcs.Graph.create () in
  print_s [%sexp { node_count = (Vcs.Graph.node_count graph : int) }];
  [%expect {| ((node_count 0)) |}];
  Vcs.Graph.add_nodes graph ~log;
  print_s [%sexp { node_count = (Vcs.Graph.node_count graph : int) }];
  [%expect {| ((node_count 180)) |}];
  List.iter refs ~f:(fun { rev; ref_kind } -> Vcs.Graph.set_ref graph ~rev ~ref_kind);
  let refs = Vcs.Graph.refs graph in
  List.iter refs ~f:(fun { rev; ref_kind } ->
    let node = Vcs.Graph.find_ref graph ~ref_kind |> Option.value_exn ~here:[%here] in
    let rev' = Vcs.Graph.rev graph node in
    require_equal [%here] (module Vcs.Rev) rev rev';
    let node' = Vcs.Graph.find_rev graph ~rev |> Option.value_exn ~here:[%here] in
    require_equal [%here] (module Vcs.Graph.Node) node node';
    let parents = Vcs.Graph.parents graph node |> List.map ~f:(Vcs.Graph.rev graph) in
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
  print_s [%sexp (Vcs.Graph.summary graph : Vcs.Graph.Summary.t)];
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
     (subgraphs (
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
    Vcs.Graph.find_ref
      graph
      ~ref_kind:(Local_branch { branch_name = Vcs.Branch_name.v "main" })
    |> Option.value_exn ~here:[%here]
  in
  let subrepo =
    Vcs.Graph.find_ref
      graph
      ~ref_kind:(Local_branch { branch_name = Vcs.Branch_name.v "subrepo" })
    |> Option.value_exn ~here:[%here]
  in
  let progress_bar =
    Vcs.Graph.find_ref
      graph
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
    Vcs.Graph.find_ref graph ~ref_kind:(Tag { tag_name = Vcs.Tag_name.v "0.0.1" })
    |> Option.value_exn ~here:[%here]
  in
  let tag_0_0_2 =
    Vcs.Graph.find_ref graph ~ref_kind:(Tag { tag_name = Vcs.Tag_name.v "0.0.2" })
    |> Option.value_exn ~here:[%here]
  in
  List.iter [ main; subrepo; progress_bar; tag_0_0_1; tag_0_0_2 ] ~f:(fun node ->
    print_s
      [%sexp
        { node = (Vcs.Graph.rev graph node : Vcs.Rev.t)
        ; refs = (Vcs.Graph.node_refs graph node : Vcs.Ref_kind.t list)
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
  (* Log. *)
  print_s [%sexp (List.length (Vcs.Graph.log graph) : int)];
  [%expect {| 180 |}];
  (* Ancestor. *)
  let is_ancestor ancestor descendant =
    print_s
      [%sexp
        { is_ancestor_or_equal =
            (Vcs.Graph.is_ancestor_or_equal graph ~ancestor ~descendant : bool)
        ; is_strict_ancestor =
            (Vcs.Graph.is_strict_ancestor graph ~ancestor ~descendant : bool)
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
  let merge_node = Vcs.Rev.v "93280971041e0e6a64894400061392b1c702baa7" in
  let root_node = Vcs.Rev.v "da46f0d60bfbb9dc9340e95f5625c10815c24af7" in
  let tip = Vcs.Rev.v "2e4fbeae154ec896262decf1ab3bee5687b93f21" in
  (* ref_kind. *)
  let node_exn rev = Vcs.Graph.find_rev graph ~rev |> Option.value_exn ~here:[%here] in
  let ref_kind rev =
    let node = node_exn rev in
    let line = Vcs.Graph.log_line graph node in
    print_s [%sexp (line : Vcs.Log.Line.t)]
  in
  ref_kind tip;
  [%expect
    {|
    (Commit
      (rev    2e4fbeae154ec896262decf1ab3bee5687b93f21)
      (parent 3820ba70563c65ee9f6d516b8e70eb5ea8173d45)) |}];
  ref_kind merge_node;
  [%expect
    {|
    (Merge
      (rev     93280971041e0e6a64894400061392b1c702baa7)
      (parent1 735103d3d41b48b7425b5b5386f235c8940080af)
      (parent2 1eafed9e1737cd2ebbfe60ca787e622c7e0fc080)) |}];
  ref_kind root_node;
  [%expect {| (Root (rev da46f0d60bfbb9dc9340e95f5625c10815c24af7)) |}];
  (* parents. *)
  let parents rev =
    let node = node_exn rev in
    let parents =
      Vcs.Graph.parents graph node |> List.map ~f:(fun node -> Vcs.Graph.rev graph node)
    in
    print_s [%sexp (parents : Vcs.Rev.t list)]
  in
  parents tip;
  [%expect {| (3820ba70563c65ee9f6d516b8e70eb5ea8173d45) |}];
  parents merge_node;
  [%expect
    {|
    (735103d3d41b48b7425b5b5386f235c8940080af
     1eafed9e1737cd2ebbfe60ca787e622c7e0fc080) |}];
  parents root_node;
  [%expect {| () |}];
  (* descendance. *)
  let test r1 r2 =
    print_s
      [%sexp
        (Vcs.Graph.descendance graph (node_exn r1) (node_exn r2)
         : Vcs.Graph.Descendance.t)]
  in
  test tip tip;
  [%expect {| Same_node |}];
  test tip root_node;
  [%expect {| Strict_descendant |}];
  test root_node tip;
  [%expect {| Strict_ancestor |}];
  let gh_page_tip = Vcs.Rev.v "7135b7f4790562e94d9122365478f0d39f5ffead" in
  test root_node gh_page_tip;
  [%expect {| Other |}];
  test gh_page_tip root_node;
  [%expect {| Other |}];
  ()
;;

(* Additional tests to help covering corner cases. *)

let%expect_test "empty summary" =
  let graph = Vcs.Graph.create () in
  print_s [%sexp (Vcs.Graph.summary graph : Vcs.Graph.Summary.t)];
  [%expect {|
    ((refs  ())
     (roots ())
     (tips  ())) |}];
  ()
;;

let%expect_test "subgraphs of empty graph" =
  let graph = Vcs.Graph.create () in
  let subgraphs = Vcs.Graph.subgraphs graph in
  print_s [%sexp (subgraphs : Vcs.Graph.Subgraph.t list)];
  [%expect {| () |}];
  ()
;;

let%expect_test "Subgraph.is_empty" =
  let subgraph = { Vcs.Graph.Subgraph.log = []; refs = [] } in
  print_s [%sexp (Vcs.Graph.Subgraph.is_empty subgraph : bool)];
  [%expect {| true |}];
  let mock_rev_gen = Vcs.Mock_rev_gen.create ~name:"test-graph" in
  let subgraph =
    { Vcs.Graph.Subgraph.log = [ Root { rev = Vcs.Mock_rev_gen.next mock_rev_gen } ]
    ; refs = []
    }
  in
  print_s [%sexp (Vcs.Graph.Subgraph.is_empty subgraph : bool)];
  [%expect {| false |}];
  ()
;;

let%expect_test "add_nodes" =
  let mock_rev_gen = Vcs.Mock_rev_gen.create ~name:"test-graph" in
  let revs = Array.init 10 ~f:(fun _ -> Vcs.Mock_rev_gen.next mock_rev_gen) in
  let log =
    (* Contrary to [git] we prepare the log with the oldest commits first, as I
       find this easier to reason about. We end up reversing the log when we add
       the nodes, to make it more alike what happens in the actual use cases. *)
    List.concat
      [ [ Vcs.Log.Line.Root { rev = revs.(0) }; Vcs.Log.Line.Root { rev = revs.(1) } ]
      ; List.init 4 ~f:(fun i ->
          Vcs.Log.Line.Commit { rev = revs.(i + 2); parent = revs.(i + 1) })
      ]
  in
  let graph = Vcs.Graph.create () in
  Vcs.Graph.add_nodes graph ~log:(List.rev log);
  print_s [%sexp (List.length (Vcs.Graph.log graph) : int)];
  [%expect {| 6 |}];
  (* Adding log is idempotent. Only new nodes are effectively added. *)
  let log =
    List.concat
      [ log
      ; [ Vcs.Log.Line.Merge { rev = revs.(6); parent1 = revs.(2); parent2 = revs.(5) } ]
      ]
  in
  Vcs.Graph.add_nodes graph ~log:(List.rev log);
  print_s [%sexp (List.length (Vcs.Graph.log graph) : int)];
  [%expect {| 7 |}];
  (* This graph has a merge node (r.6) which present some corner cases for the
     logic in [is_strict_ancestor] that are hard to cover otherwise. *)
  let node_exn rev = Vcs.Graph.find_rev graph ~rev |> Option.value_exn ~here:[%here] in
  print_s [%sexp (Vcs.Graph.log graph : Vcs.Log.t)];
  [%expect
    {|
    ((Root (rev 5cd237e9598b11065c344d1eb33bc8c15cd237e9))
     (Root (rev f453b802f640c6888df978c712057d17f453b802))
     (Commit
       (rev    5deb4aaec51a75ef58765038b7c20b3f5deb4aae)
       (parent f453b802f640c6888df978c712057d17f453b802))
     (Commit
       (rev    9a81fba7a18f740120f1141b1ed109bb9a81fba7)
       (parent 5deb4aaec51a75ef58765038b7c20b3f5deb4aae))
     (Commit
       (rev    7216231cd107946841cc3eebe5da287b7216231c)
       (parent 9a81fba7a18f740120f1141b1ed109bb9a81fba7))
     (Commit
       (rev    b155b82523d24ea82eb0ad45a5e89adcb155b825)
       (parent 7216231cd107946841cc3eebe5da287b7216231c))
     (Merge
       (rev     ed2a9ed9f5d7bee45156ba272651656ced2a9ed9)
       (parent1 5deb4aaec51a75ef58765038b7c20b3f5deb4aae)
       (parent2 b155b82523d24ea82eb0ad45a5e89adcb155b825)))
    |}];
  let is_strict_ancestor r1 r2 =
    print_s
      [%sexp
        (Vcs.Graph.is_strict_ancestor
           graph
           ~ancestor:(node_exn r1)
           ~descendant:(node_exn r2)
         : bool)]
  in
  is_strict_ancestor revs.(1) revs.(6);
  [%expect {| true |}];
  is_strict_ancestor revs.(3) revs.(6);
  [%expect {| true |}];
  is_strict_ancestor revs.(0) revs.(6);
  [%expect {| false |}];
  ()
;;

let%expect_test "set invalid rev" =
  let mock_rev_gen = Vcs.Mock_rev_gen.create ~name:"test-graph" in
  let r1 = Vcs.Mock_rev_gen.next mock_rev_gen in
  let graph = Vcs.Graph.create () in
  let set_ref_r1 () =
    Vcs.Graph.set_ref
      graph
      ~rev:r1
      ~ref_kind:(Local_branch { branch_name = Vcs.Branch_name.v "main" })
  in
  require_does_raise [%here] (fun () -> set_ref_r1 ());
  [%expect {| (Vcs.E ("Rev not found" 5cd237e9598b11065c344d1eb33bc8c15cd237e9)) |}];
  Vcs.Graph.add_nodes graph ~log:[ Root { rev = r1 } ];
  set_ref_r1 ();
  print_s [%sexp (Vcs.Graph.refs graph : Vcs.Refs.t)];
  [%expect
    {|
    ((
      (rev 5cd237e9598b11065c344d1eb33bc8c15cd237e9)
      (ref_kind (Local_branch (branch_name main)))))
    |}];
  ()
;;

let%expect_test "greatest_common_ancestors" =
  let mock_rev_gen = Vcs.Mock_rev_gen.create ~name:"test-graph" in
  let rev () = Vcs.Mock_rev_gen.next mock_rev_gen in
  let graph = Vcs.Graph.create () in
  let node ~rev = Vcs.Graph.find_rev graph ~rev |> Option.value_exn ~here:[%here] in
  let tag ~rev tag_name =
    Vcs.Graph.set_ref graph ~rev ~ref_kind:(Tag { tag_name = Vcs.Tag_name.v tag_name })
  in
  let root () =
    let rev = rev () in
    Vcs.Graph.add_nodes graph ~log:[ Vcs.Log.Line.Root { rev } ];
    rev
  in
  let commit ~parent =
    let rev = rev () in
    Vcs.Graph.add_nodes graph ~log:[ Vcs.Log.Line.Commit { rev; parent } ];
    rev
  in
  let merge ~parent1 ~parent2 =
    let rev = rev () in
    Vcs.Graph.add_nodes graph ~log:[ Vcs.Log.Line.Merge { rev; parent1; parent2 } ];
    rev
  in
  let gcas revs =
    let gcas =
      Vcs.Graph.greatest_common_ancestors graph (List.map revs ~f:(fun rev -> node ~rev))
      |> List.map ~f:(fun node ->
        match Vcs.Graph.node_refs graph node with
        | ref :: _ -> Vcs.Ref_kind.to_string ref
        | [] ->
          (* This branch is kept for debug if it is executed by mistake but we
             shouldn't exercise this case since this makes the tests results
             harder to understand. *)
          (Vcs.Graph.rev graph node |> Vcs.Rev.to_string) [@coverage off])
    in
    print_s [%sexp { gcas : string list }]
  in
  gcas [];
  [%expect {| ((gcas ())) |}];
  let root1 = root () in
  tag ~rev:root1 "root1";
  gcas [ root1 ];
  [%expect {| ((gcas (refs/tags/root1))) |}];
  let r1 = commit ~parent:root1 in
  tag ~rev:r1 "r1";
  gcas [ r1 ];
  [%expect {| ((gcas (refs/tags/r1))) |}];
  gcas [ root1; r1 ];
  [%expect {| ((gcas (refs/tags/root1))) |}];
  let m1 = merge ~parent1:root1 ~parent2:r1 in
  tag ~rev:m1 "m1";
  gcas [ m1 ];
  [%expect {| ((gcas (refs/tags/m1))) |}];
  gcas [ root1; m1 ];
  [%expect {| ((gcas (refs/tags/root1))) |}];
  gcas [ r1; m1 ];
  [%expect {| ((gcas (refs/tags/r1))) |}];
  gcas [ root1; r1; m1 ];
  [%expect {| ((gcas (refs/tags/root1))) |}];
  let root2 = root () in
  tag ~rev:root2 "root2";
  gcas [ root1; root2 ];
  [%expect {| ((gcas ())) |}];
  gcas [ r1; root2 ];
  [%expect {| ((gcas ())) |}];
  let r2 =
    List.fold (List.init 10 ~f:ignore) ~init:r1 ~f:(fun parent () -> commit ~parent)
  in
  let r3 =
    List.fold (List.init 10 ~f:ignore) ~init:m1 ~f:(fun parent () -> commit ~parent)
  in
  gcas [ r2; r3 ];
  [%expect {| ((gcas (refs/tags/r1))) |}];
  (* A criss-cross merge. *)
  let alice = commit ~parent:r1 in
  tag ~rev:alice "alice";
  let bob = commit ~parent:r1 in
  tag ~rev:bob "bob";
  let alice_merge = merge ~parent1:alice ~parent2:bob in
  let bob_merge = merge ~parent1:bob ~parent2:alice in
  let alice_continue = commit ~parent:alice_merge in
  let bob_continue = commit ~parent:bob_merge in
  gcas [ alice_continue; bob_continue ];
  [%expect {| ((gcas (refs/tags/alice refs/tags/bob))) |}];
  ()
;;

(* In this part of the test, we want to monitor that the interface exposed by
   [Vcs.Graph] is sufficient to write some algorithm on git graphs. As an example
   here, we are implementing from the user land a function that returns the set
   of nodes that are ancestors of a given node. *)

let ancestors graph node =
  let rec loop acc to_visit =
    match to_visit with
    | [] -> acc
    | node :: to_visit ->
      if Set.mem acc node
      then loop acc to_visit
      else loop (Set.add acc node) (Vcs.Graph.prepend_parents graph node to_visit)
  in
  loop (Set.empty (module Vcs_base.Vcs.Graph.Node)) [ node ]
;;

let%expect_test "debug graph" =
  (* If needed, sexp_of_t should show helpful indices for nodes. *)
  let mock_rev_gen = Vcs.Mock_rev_gen.create ~name:"test-graph" in
  let rev () = Vcs.Mock_rev_gen.next mock_rev_gen in
  let graph = Vcs.Graph.create () in
  let node ~rev = Vcs.Graph.find_rev graph ~rev |> Option.value_exn ~here:[%here] in
  let root () =
    let rev = rev () in
    Vcs.Graph.add_nodes graph ~log:[ Vcs.Log.Line.Root { rev } ];
    rev
  in
  let commit ~parent =
    let rev = rev () in
    Vcs.Graph.add_nodes graph ~log:[ Vcs.Log.Line.Commit { rev; parent } ];
    rev
  in
  let merge ~parent1 ~parent2 =
    let rev = rev () in
    Vcs.Graph.add_nodes graph ~log:[ Vcs.Log.Line.Merge { rev; parent1; parent2 } ];
    rev
  in
  let r1 = root () in
  let r2 = commit ~parent:r1 in
  let r3 = commit ~parent:r1 in
  let m1 = merge ~parent1:r2 ~parent2:r3 in
  let r4 = commit ~parent:m1 in
  Vcs.Graph.set_refs
    graph
    ~refs:
      [ { rev = r2
        ; ref_kind =
            Remote_branch { remote_branch_name = Vcs.Remote_branch_name.v "origin/main" }
        }
      ; { rev = r4; ref_kind = Tag { tag_name = Vcs.Tag_name.v "0.1.0" } }
      ; { rev = r4; ref_kind = Local_branch { branch_name = Vcs.Branch_name.main } }
      ];
  print_s [%sexp (graph : Vcs.Graph.t)];
  [%expect
    {|
    ((nodes (
       (#4 (
         Commit
         (rev    7216231cd107946841cc3eebe5da287b7216231c)
         (parent #3)))
       (#3 (
         Merge
         (rev     9a81fba7a18f740120f1141b1ed109bb9a81fba7)
         (parent1 #1)
         (parent2 #2)))
       (#2 (
         Commit
         (rev    5deb4aaec51a75ef58765038b7c20b3f5deb4aae)
         (parent #0)))
       (#1 (
         Commit
         (rev    f453b802f640c6888df978c712057d17f453b802)
         (parent #0)))
       (#0 (Root (rev 5cd237e9598b11065c344d1eb33bc8c15cd237e9)))))
     (revs (
       (#4 7216231cd107946841cc3eebe5da287b7216231c)
       (#3 9a81fba7a18f740120f1141b1ed109bb9a81fba7)
       (#2 5deb4aaec51a75ef58765038b7c20b3f5deb4aae)
       (#1 f453b802f640c6888df978c712057d17f453b802)
       (#0 5cd237e9598b11065c344d1eb33bc8c15cd237e9)))
     (refs (
       (#4 (
         (Local_branch (branch_name main))
         (Tag          (tag_name    0.1.0))))
       (#1 ((
         Remote_branch (
           remote_branch_name (
             (remote_name origin)
             (branch_name main)))))))))
    |}];
  (* node_count *)
  print_s [%sexp { node_count = (Vcs.Graph.node_count graph : int) }];
  [%expect {| ((node_count 5)) |}];
  (* node_kind *)
  let node_kind rev =
    let node = node ~rev in
    print_s [%sexp (Vcs.Graph.node_kind graph node : Vcs.Graph.Node_kind.t)]
  in
  node_kind r1;
  [%expect {| (Root (rev 5cd237e9598b11065c344d1eb33bc8c15cd237e9)) |}];
  node_kind r2;
  [%expect
    {|
    (Commit
      (rev    f453b802f640c6888df978c712057d17f453b802)
      (parent #0))
    |}];
  node_kind m1;
  [%expect
    {|
    (Merge
      (rev     9a81fba7a18f740120f1141b1ed109bb9a81fba7)
      (parent1 #1)
      (parent2 #2))
    |}];
  node_kind r4;
  [%expect
    {|
    (Commit
      (rev    7216231cd107946841cc3eebe5da287b7216231c)
      (parent #3))
    |}];
  (* ancestors *)
  let print_ancestors rev =
    print_s [%sexp (ancestors graph (node ~rev) : Set.M(Vcs.Graph.Node).t)]
  in
  print_ancestors r1;
  [%expect {| (#0) |}];
  print_ancestors r2;
  [%expect {| (#0 #1) |}];
  print_ancestors r3;
  [%expect {| (#0 #2) |}];
  print_ancestors m1;
  [%expect {| (#0 #1 #2 #3) |}];
  print_ancestors r4;
  [%expect {| (#0 #1 #2 #3 #4) |}];
  (* Low level int indexing. *)
  let node_index node = print_s [%sexp (Vcs.Graph.node_index node : int)] in
  node_index (node ~rev:r1);
  [%expect {| 0 |}];
  node_index (node ~rev:r4);
  [%expect {| 4 |}];
  let get_node_exn index =
    print_s [%sexp (Vcs.Graph.get_node_exn graph ~index : Vcs.Graph.Node.t)]
  in
  get_node_exn 0;
  [%expect {| #0 |}];
  get_node_exn 4;
  [%expect {| #4 |}];
  require_does_raise [%here] (fun () -> get_node_exn 5);
  [%expect
    {|
    (Vcs.E (
      "Node index out of bounds" (
        (index      5)
        (node_count 5))))
    |}];
  require_does_raise [%here] (fun () -> get_node_exn (-1));
  [%expect
    {|
    (Vcs.E (
      "Node index out of bounds" (
        (index      -1)
        (node_count 5))))
    |}];
  ()
;;
