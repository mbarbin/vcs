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

let%expect_test "graph" =
  Eio_main.run
  @@ fun env ->
  let log =
    let path = Eio.Path.(Eio.Stdenv.fs env / "super-master-mind.log") in
    let contents = Eio.Path.load path in
    let lines = String.split_lines contents in
    List.map lines ~f:(fun line -> Volgo_git_backend.Log.parse_log_line_exn ~line)
  in
  let refs =
    let path = Eio.Path.(Eio.Stdenv.fs env / "super-master-mind.refs") in
    let contents = Eio.Path.load path in
    let lines = String.split_lines contents in
    Volgo_git_backend.Refs.parse_lines_exn ~lines
  in
  let graph = Vcs.Graph.create () in
  print_dyn (Dyn.record [ "node_count", Vcs.Graph.node_count graph |> Dyn.int ]);
  [%expect {| { node_count = 0 } |}];
  Vcs.Graph.add_nodes graph ~log;
  print_dyn (Dyn.record [ "node_count", Vcs.Graph.node_count graph |> Dyn.int ]);
  [%expect {| { node_count = 180 } |}];
  List.iter refs ~f:(fun { rev; ref_kind } -> Vcs.Graph.set_ref graph ~rev ~ref_kind);
  let refs = Vcs.Graph.refs graph in
  List.iter refs ~f:(fun { rev; ref_kind } ->
    let node = Vcs.Graph.find_ref graph ~ref_kind |> Option.get in
    let rev' = Vcs.Graph.rev graph ~node in
    require_equal (module Vcs.Rev) rev rev';
    let node' = Vcs.Graph.find_rev graph ~rev |> Option.get in
    require_equal (module Vcs.Graph.Node) node node';
    let parents =
      Vcs.Graph.parents graph ~node |> List.map ~f:(fun node -> Vcs.Graph.rev graph ~node)
    in
    print_dyn
      (Dyn.record
         [ "ref_kind", ref_kind |> Vcs.Ref_kind.to_dyn
         ; "rev", rev |> Vcs.Rev.to_dyn
         ; "parents", parents |> Dyn.list Vcs.Rev.to_dyn
         ]));
  [%expect
    {|
    { ref_kind = Local_branch { branch_name = "gh-pages" }
    ; rev = "7135b7f4790562e94d9122365478f0d39f5ffead"
    ; parents = [ "ad9e24e4ee719d71b07ce29597818461b38c9e4a" ]
    }
    { ref_kind = Local_branch { branch_name = "main" }
    ; rev = "2e4fbeae154ec896262decf1ab3bee5687b93f21"
    ; parents = [ "3820ba70563c65ee9f6d516b8e70eb5ea8173d45" ]
    }
    { ref_kind = Local_branch { branch_name = "subrepo" }
    ; rev = "2e4fbeae154ec896262decf1ab3bee5687b93f21"
    ; parents = [ "3820ba70563c65ee9f6d516b8e70eb5ea8173d45" ]
    }
    { ref_kind =
        Remote_branch
          { remote_branch_name =
              { remote_name = "origin"; branch_name = "0.0.3-preview" }
          }
    ; rev = "8e0e6821261f8baaff7bf4d6820c41417bab91eb"
    ; parents = [ "1887c81ebf9b84c548bc35038f7af82a18eb77bf" ]
    }
    { ref_kind =
        Remote_branch
          { remote_branch_name =
              { remote_name = "origin"; branch_name = "gh-pages" }
          }
    ; rev = "7135b7f4790562e94d9122365478f0d39f5ffead"
    ; parents = [ "ad9e24e4ee719d71b07ce29597818461b38c9e4a" ]
    }
    { ref_kind =
        Remote_branch
          { remote_branch_name = { remote_name = "origin"; branch_name = "main" }
          }
    ; rev = "2e4fbeae154ec896262decf1ab3bee5687b93f21"
    ; parents = [ "3820ba70563c65ee9f6d516b8e70eb5ea8173d45" ]
    }
    { ref_kind =
        Remote_branch
          { remote_branch_name =
              { remote_name = "origin"; branch_name = "progress-bar" }
          }
    ; rev = "a2cc521adbc8dcbd4855968698176e8af54f6550"
    ; parents = [ "4fbe82806f16bac64c099fa28300efe4a3c7c478" ]
    }
    { ref_kind =
        Remote_branch
          { remote_branch_name =
              { remote_name = "origin"; branch_name = "progress-bar.2" }
          }
    ; rev = "7500919364fb176946e7598051ca7247addc3d15"
    ; parents = [ "ad01432770d3f696cf9312a6a45a559e3d2ac814" ]
    }
    { ref_kind = Tag { tag_name = "0.0.1" }
    ; rev = "1892d4980ee74945eb98f67be26b745f96c0f482"
    ; parents = [ "728e5a4ebfaa8564358b17fd754dacea9a6b0153" ]
    }
    { ref_kind = Tag { tag_name = "0.0.2" }
    ; rev = "0d4750ff594236a4bd970e1c90b8bbad80fcadff"
    ; parents = [ "11c7861ae090e2dc5e2400d4d8a90c74b0a37163" ]
    }
    { ref_kind = Tag { tag_name = "0.0.3" }
    ; rev = "fc8e67fbc47302b7da682e9a7da626790bb59eaa"
    ; parents = [ "6e463fbe6765015b8427f004f856ee4d77cc9ccd" ]
    }
    { ref_kind = Tag { tag_name = "0.0.3-preview.1" }
    ; rev = "1887c81ebf9b84c548bc35038f7af82a18eb77bf"
    ; parents = [ "b258b0cde128083c4f05bcf276bcc1322f1d36a2" ]
    }
    |}];
  print_dyn (Vcs.Graph.summary graph |> Vcs.Graph.Summary.to_dyn);
  [%expect
    {|
    { refs =
        [ ("7135b7f4790562e94d9122365478f0d39f5ffead", "refs/heads/gh-pages")
        ; ("2e4fbeae154ec896262decf1ab3bee5687b93f21", "refs/heads/main")
        ; ("2e4fbeae154ec896262decf1ab3bee5687b93f21", "refs/heads/subrepo")
        ; ("8e0e6821261f8baaff7bf4d6820c41417bab91eb",
           "refs/remotes/origin/0.0.3-preview")
        ; ("7135b7f4790562e94d9122365478f0d39f5ffead",
           "refs/remotes/origin/gh-pages")
        ; ("2e4fbeae154ec896262decf1ab3bee5687b93f21", "refs/remotes/origin/main")
        ; ("a2cc521adbc8dcbd4855968698176e8af54f6550",
           "refs/remotes/origin/progress-bar")
        ; ("7500919364fb176946e7598051ca7247addc3d15",
           "refs/remotes/origin/progress-bar.2")
        ; ("1892d4980ee74945eb98f67be26b745f96c0f482", "refs/tags/0.0.1")
        ; ("0d4750ff594236a4bd970e1c90b8bbad80fcadff", "refs/tags/0.0.2")
        ; ("fc8e67fbc47302b7da682e9a7da626790bb59eaa", "refs/tags/0.0.3")
        ; ("1887c81ebf9b84c548bc35038f7af82a18eb77bf",
           "refs/tags/0.0.3-preview.1")
        ]
    ; roots =
        [ "da46f0d60bfbb9dc9340e95f5625c10815c24af7"
        ; "35760b109070be51b9deb61c8fdc79c0b2d9065d"
        ]
    ; leaves =
        [ ("a2cc521adbc8dcbd4855968698176e8af54f6550",
           [ "refs/remotes/origin/progress-bar" ])
        ; ("8e0e6821261f8baaff7bf4d6820c41417bab91eb",
           [ "refs/remotes/origin/0.0.3-preview" ])
        ; ("7500919364fb176946e7598051ca7247addc3d15",
           [ "refs/remotes/origin/progress-bar.2" ])
        ; ("7135b7f4790562e94d9122365478f0d39f5ffead",
           [ "refs/heads/gh-pages"; "refs/remotes/origin/gh-pages" ])
        ; ("2e4fbeae154ec896262decf1ab3bee5687b93f21",
           [ "refs/heads/main"
           ; "refs/heads/subrepo"
           ; "refs/remotes/origin/main"
           ])
        ]
    ; subgraphs =
        [ { refs =
              [ ("2e4fbeae154ec896262decf1ab3bee5687b93f21", "refs/heads/main")
              ; ("2e4fbeae154ec896262decf1ab3bee5687b93f21", "refs/heads/subrepo")
              ; ("8e0e6821261f8baaff7bf4d6820c41417bab91eb",
                 "refs/remotes/origin/0.0.3-preview")
              ; ("2e4fbeae154ec896262decf1ab3bee5687b93f21",
                 "refs/remotes/origin/main")
              ; ("a2cc521adbc8dcbd4855968698176e8af54f6550",
                 "refs/remotes/origin/progress-bar")
              ; ("7500919364fb176946e7598051ca7247addc3d15",
                 "refs/remotes/origin/progress-bar.2")
              ; ("1892d4980ee74945eb98f67be26b745f96c0f482", "refs/tags/0.0.1")
              ; ("0d4750ff594236a4bd970e1c90b8bbad80fcadff", "refs/tags/0.0.2")
              ; ("fc8e67fbc47302b7da682e9a7da626790bb59eaa", "refs/tags/0.0.3")
              ; ("1887c81ebf9b84c548bc35038f7af82a18eb77bf",
                 "refs/tags/0.0.3-preview.1")
              ]
          ; roots = [ "da46f0d60bfbb9dc9340e95f5625c10815c24af7" ]
          ; leaves =
              [ ("2e4fbeae154ec896262decf1ab3bee5687b93f21",
                 [ "refs/heads/main"
                 ; "refs/heads/subrepo"
                 ; "refs/remotes/origin/main"
                 ])
              ; ("7500919364fb176946e7598051ca7247addc3d15",
                 [ "refs/remotes/origin/progress-bar.2" ])
              ; ("8e0e6821261f8baaff7bf4d6820c41417bab91eb",
                 [ "refs/remotes/origin/0.0.3-preview" ])
              ; ("a2cc521adbc8dcbd4855968698176e8af54f6550",
                 [ "refs/remotes/origin/progress-bar" ])
              ]
          }
        ; { refs =
              [ ("7135b7f4790562e94d9122365478f0d39f5ffead",
                 "refs/heads/gh-pages")
              ; ("7135b7f4790562e94d9122365478f0d39f5ffead",
                 "refs/remotes/origin/gh-pages")
              ]
          ; roots = [ "35760b109070be51b9deb61c8fdc79c0b2d9065d" ]
          ; leaves =
              [ ("7135b7f4790562e94d9122365478f0d39f5ffead",
                 [ "refs/heads/gh-pages"; "refs/remotes/origin/gh-pages" ])
              ]
          }
        ]
    }
    |}];
  let main =
    Vcs.Graph.find_ref
      graph
      ~ref_kind:(Local_branch { branch_name = Vcs.Branch_name.v "main" })
    |> Option.get
  in
  let subrepo =
    Vcs.Graph.find_ref
      graph
      ~ref_kind:(Local_branch { branch_name = Vcs.Branch_name.v "subrepo" })
    |> Option.get
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
    |> Option.get
  in
  let tag_0_0_1 =
    Vcs.Graph.find_ref graph ~ref_kind:(Tag { tag_name = Vcs.Tag_name.v "0.0.1" })
    |> Option.get
  in
  let tag_0_0_2 =
    Vcs.Graph.find_ref graph ~ref_kind:(Tag { tag_name = Vcs.Tag_name.v "0.0.2" })
    |> Option.get
  in
  List.iter [ main; subrepo; progress_bar; tag_0_0_1; tag_0_0_2 ] ~f:(fun node ->
    print_dyn
      (Dyn.record
         [ "node", Vcs.Graph.rev graph ~node |> Vcs.Rev.to_dyn
         ; "refs", Vcs.Graph.node_refs graph ~node |> Dyn.list Vcs.Ref_kind.to_dyn
         ]));
  [%expect
    {|
    { node = "2e4fbeae154ec896262decf1ab3bee5687b93f21"
    ; refs =
        [ Local_branch { branch_name = "main" }
        ; Local_branch { branch_name = "subrepo" }
        ; Remote_branch
            { remote_branch_name =
                { remote_name = "origin"; branch_name = "main" }
            }
        ]
    }
    { node = "2e4fbeae154ec896262decf1ab3bee5687b93f21"
    ; refs =
        [ Local_branch { branch_name = "main" }
        ; Local_branch { branch_name = "subrepo" }
        ; Remote_branch
            { remote_branch_name =
                { remote_name = "origin"; branch_name = "main" }
            }
        ]
    }
    { node = "a2cc521adbc8dcbd4855968698176e8af54f6550"
    ; refs =
        [ Remote_branch
            { remote_branch_name =
                { remote_name = "origin"; branch_name = "progress-bar" }
            }
        ]
    }
    { node = "1892d4980ee74945eb98f67be26b745f96c0f482"
    ; refs = [ Tag { tag_name = "0.0.1" } ]
    }
    { node = "0d4750ff594236a4bd970e1c90b8bbad80fcadff"
    ; refs = [ Tag { tag_name = "0.0.2" } ]
    }
    |}];
  (* Log. *)
  print_dyn (List.length (Vcs.Graph.log graph) |> Dyn.int);
  [%expect {| 180 |}];
  (* Ancestor. *)
  let is_ancestor ancestor descendant =
    print_dyn
      (Dyn.record
         [ ( "is_ancestor_or_equal"
           , Vcs.Graph.is_ancestor_or_equal graph ~ancestor ~descendant |> Dyn.bool )
         ; ( "is_strict_ancestor"
           , Vcs.Graph.is_strict_ancestor graph ~ancestor ~descendant |> Dyn.bool )
         ])
  in
  is_ancestor tag_0_0_1 tag_0_0_2;
  [%expect {| { is_ancestor_or_equal = true; is_strict_ancestor = true } |}];
  is_ancestor tag_0_0_2 tag_0_0_1;
  [%expect {| { is_ancestor_or_equal = false; is_strict_ancestor = false } |}];
  is_ancestor main main;
  [%expect {| { is_ancestor_or_equal = true; is_strict_ancestor = false } |}];
  let merge_node = Vcs.Rev.v "93280971041e0e6a64894400061392b1c702baa7" in
  let root_node = Vcs.Rev.v "da46f0d60bfbb9dc9340e95f5625c10815c24af7" in
  let tip = Vcs.Rev.v "2e4fbeae154ec896262decf1ab3bee5687b93f21" in
  (* ref_kind. *)
  let node_exn rev = Vcs.Graph.find_rev graph ~rev |> Option.get in
  let ref_kind rev =
    let node = node_exn rev in
    let line = Vcs.Graph.log_line graph ~node in
    print_dyn (line |> Vcs.Log.Line.to_dyn)
  in
  ref_kind tip;
  [%expect
    {|
    Commit
      { rev = "2e4fbeae154ec896262decf1ab3bee5687b93f21"
      ; parent = "3820ba70563c65ee9f6d516b8e70eb5ea8173d45"
      }
    |}];
  ref_kind merge_node;
  [%expect
    {|
    Merge
      { rev = "93280971041e0e6a64894400061392b1c702baa7"
      ; parent1 = "735103d3d41b48b7425b5b5386f235c8940080af"
      ; parent2 = "1eafed9e1737cd2ebbfe60ca787e622c7e0fc080"
      }
    |}];
  ref_kind root_node;
  [%expect {| Root { rev = "da46f0d60bfbb9dc9340e95f5625c10815c24af7" } |}];
  (* parents. *)
  let parents rev =
    let node = node_exn rev in
    let parent_count = Vcs.Graph.parent_count graph ~node in
    let parents =
      Vcs.Graph.parents graph ~node |> List.map ~f:(fun node -> Vcs.Graph.rev graph ~node)
    in
    print_dyn
      (Dyn.record
         [ "parent_count", parent_count |> Dyn.int
         ; "parents", parents |> Dyn.list Vcs.Rev.to_dyn
         ])
  in
  parents tip;
  [%expect
    {|
    { parent_count = 1
    ; parents = [ "3820ba70563c65ee9f6d516b8e70eb5ea8173d45" ]
    }
    |}];
  parents merge_node;
  [%expect
    {|
    { parent_count = 2
    ; parents =
        [ "735103d3d41b48b7425b5b5386f235c8940080af"
        ; "1eafed9e1737cd2ebbfe60ca787e622c7e0fc080"
        ]
    }
    |}];
  parents root_node;
  [%expect {| { parent_count = 0; parents = [] } |}];
  (* descendance. *)
  let test r1 r2 =
    print_dyn
      (Vcs.Graph.descendance graph (node_exn r1) (node_exn r2)
       |> Vcs.Graph.Descendance.to_dyn)
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
  print_dyn (Vcs.Graph.summary graph |> Vcs.Graph.Summary.to_dyn);
  [%expect {| { refs = []; roots = []; leaves = [] } |}];
  ()
;;

let%expect_test "subgraphs of empty graph" =
  let graph = Vcs.Graph.create () in
  let subgraphs = Vcs.Graph.subgraphs graph in
  print_dyn (Dyn.list Vcs.Graph.Subgraph.to_dyn subgraphs);
  [%expect {| [] |}];
  ()
;;

module Line = struct
  let root ~rev = Vcs.Log.Line.create ~rev ~parents:[]
  let commit ~rev ~parent = Vcs.Log.Line.create ~rev ~parents:[ parent ]

  let merge ~rev ~parent1 ~parent2 =
    Vcs.Log.Line.create ~rev ~parents:[ parent1; parent2 ]
  ;;
end

let%expect_test "Subgraph.is_empty" =
  let subgraph = { Vcs.Graph.Subgraph.log = []; refs = [] } in
  print_dyn (Vcs.Graph.Subgraph.is_empty subgraph |> Dyn.bool);
  [%expect {| true |}];
  let mock_rev_gen = Vcs.Mock_rev_gen.create ~name:"test-graph" in
  let subgraph =
    { Vcs.Graph.Subgraph.log = [ Line.root ~rev:(Vcs.Mock_rev_gen.next mock_rev_gen) ]
    ; refs = []
    }
  in
  print_dyn (Vcs.Graph.Subgraph.is_empty subgraph |> Dyn.bool);
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
      [ [ Line.root ~rev:revs.(0); Line.root ~rev:revs.(1) ]
      ; List.init ~len:4 ~f:(fun i -> Line.commit ~rev:revs.(i + 2) ~parent:revs.(i + 1))
      ]
  in
  let graph = Vcs.Graph.create () in
  Vcs.Graph.add_nodes graph ~log:(List.rev log);
  print_dyn (List.length (Vcs.Graph.log graph) |> Dyn.int);
  [%expect {| 6 |}];
  (* Adding log is idempotent. Only new nodes are effectively added. *)
  let log =
    List.concat [ log; [ Line.merge ~rev:revs.(6) ~parent1:revs.(2) ~parent2:revs.(5) ] ]
  in
  Vcs.Graph.add_nodes graph ~log:(List.rev log);
  print_dyn (List.length (Vcs.Graph.log graph) |> Dyn.int);
  [%expect {| 7 |}];
  (* This graph has a merge node (r.6) which present some corner cases for the
     logic in [is_strict_ancestor] that are hard to cover otherwise. *)
  let node_exn rev = Vcs.Graph.find_rev graph ~rev |> Option.get in
  print_dyn (Vcs.Graph.log graph |> Vcs.Log.to_dyn);
  [%expect
    {|
    [ Root { rev = "5cd237e9598b11065c344d1eb33bc8c15cd237e9" }
    ; Root { rev = "f453b802f640c6888df978c712057d17f453b802" }
    ; Commit
        { rev = "5deb4aaec51a75ef58765038b7c20b3f5deb4aae"
        ; parent = "f453b802f640c6888df978c712057d17f453b802"
        }
    ; Commit
        { rev = "9a81fba7a18f740120f1141b1ed109bb9a81fba7"
        ; parent = "5deb4aaec51a75ef58765038b7c20b3f5deb4aae"
        }
    ; Commit
        { rev = "7216231cd107946841cc3eebe5da287b7216231c"
        ; parent = "9a81fba7a18f740120f1141b1ed109bb9a81fba7"
        }
    ; Commit
        { rev = "b155b82523d24ea82eb0ad45a5e89adcb155b825"
        ; parent = "7216231cd107946841cc3eebe5da287b7216231c"
        }
    ; Merge
        { rev = "ed2a9ed9f5d7bee45156ba272651656ced2a9ed9"
        ; parent1 = "5deb4aaec51a75ef58765038b7c20b3f5deb4aae"
        ; parent2 = "b155b82523d24ea82eb0ad45a5e89adcb155b825"
        }
    ]
    |}];
  let is_strict_ancestor r1 r2 =
    print_dyn
      (Vcs.Graph.is_strict_ancestor
         graph
         ~ancestor:(node_exn r1)
         ~descendant:(node_exn r2)
       |> Dyn.bool)
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
  require_does_raise (fun () -> set_ref_r1 ());
  [%expect
    {|
    ("Rev not found.",
     { rev = "5cd237e9598b11065c344d1eb33bc8c15cd237e9"
     ; ref_kind = Local_branch { branch_name = "main" }
     })
    |}];
  Vcs.Graph.add_nodes graph ~log:[ Line.root ~rev:r1 ];
  set_ref_r1 ();
  print_dyn (Vcs.Graph.refs graph |> Vcs.Refs.to_dyn);
  [%expect
    {|
    [ { rev = "5cd237e9598b11065c344d1eb33bc8c15cd237e9"
      ; ref_kind = Local_branch { branch_name = "main" }
      }
    ]
    |}];
  ()
;;

let%expect_test "octopus_merge" =
  (* This test monitors the support for octopus merges implemented in vcs. *)
  let mock_rev_gen = Vcs.Mock_rev_gen.create ~name:"octopus-graph" in
  let len = 5 in
  let revs = Array.init 5 ~f:(fun _ -> Vcs.Mock_rev_gen.next mock_rev_gen) in
  let oct = Vcs.Mock_rev_gen.next mock_rev_gen in
  let graph = Vcs.Graph.create () in
  let log =
    List.concat
      [ [ Line.root ~rev:revs.(0) ]
      ; List.init ~len:(len - 1) ~f:(fun i ->
          Line.commit ~rev:revs.(i + 1) ~parent:revs.(i))
      ; [ Vcs.Log.Line.create ~rev:oct ~parents:(Array.to_list revs) ]
      ]
  in
  print_dyn (Dyn.Record [ "roots", Vcs.Log.roots log |> Dyn.list Vcs.Rev.to_dyn ]);
  [%expect {| { roots = [ "bfd32f3af3313cad34fd988e3135a891bfd32f3a" ] } |}];
  Vcs.Graph.add_nodes graph ~log:(List.rev log);
  [%expect {||}];
  print_dyn (List.length (Vcs.Graph.log graph) |> Dyn.int);
  [%expect {| 6 |}];
  print_dyn (Vcs.Graph.log graph |> Vcs.Log.to_dyn);
  [%expect
    {|
    [ Root { rev = "bfd32f3af3313cad34fd988e3135a891bfd32f3a" }
    ; Commit
        { rev = "a84ce8227bc12bf8e1bb8ca3b2a350b8a84ce822"
        ; parent = "bfd32f3af3313cad34fd988e3135a891bfd32f3a"
        }
    ; Commit
        { rev = "db529706776748aef99c04f4e71457e5db529706"
        ; parent = "a84ce8227bc12bf8e1bb8ca3b2a350b8a84ce822"
        }
    ; Commit
        { rev = "e80940773fa5563bc1708976ce1c29f3e8094077"
        ; parent = "db529706776748aef99c04f4e71457e5db529706"
        }
    ; Commit
        { rev = "e797f5f4f71cb1c58260feee65acea0ee797f5f4"
        ; parent = "e80940773fa5563bc1708976ce1c29f3e8094077"
        }
    ; Octopus_merge
        { rev = "5ef28c38bcaa95fe160c24835e478d0a5ef28c38"
        ; parent1 = "bfd32f3af3313cad34fd988e3135a891bfd32f3a"
        ; parent2 = "a84ce8227bc12bf8e1bb8ca3b2a350b8a84ce822"
        ; parent3 = "db529706776748aef99c04f4e71457e5db529706"
        ; parent4 = "e80940773fa5563bc1708976ce1c29f3e8094077"
        ; parent5 = "e797f5f4f71cb1c58260feee65acea0ee797f5f4"
        }
    ]
    |}];
  (* Code coverage for octopus node kinds. *)
  print_dyn (Vcs.Graph.roots graph |> Dyn.list Vcs.Graph.Node.to_dyn);
  [%expect {| [ "#0" ] |}];
  let oct_node = Vcs.Graph.find_rev graph ~rev:oct |> Option.get in
  print_dyn (Vcs.Graph.node_kind graph ~node:oct_node |> Vcs.Graph.Node_kind.to_dyn);
  [%expect
    {|
    Octopus_merge
      { rev = "5ef28c38bcaa95fe160c24835e478d0a5ef28c38"
      ; parent1 = "#0"
      ; parent2 = "#1"
      ; parent3 = "#2"
      ; parent4 = "#3"
      ; parent5 = "#4"
      }
    |}];
  print_dyn (Vcs.Graph.parent_count graph ~node:oct_node |> Dyn.int);
  [%expect {| 5 |}];
  print_dyn
    (Vcs.Graph.prepend_parents graph ~node:oct_node ~prepend_to:[]
     |> Dyn.list Vcs.Graph.Node.to_dyn);
  [%expect {| [ "#0"; "#1"; "#2"; "#3"; "#4" ] |}];
  let subgraphs = Vcs.Graph.subgraphs graph in
  print_dyn (Dyn.Record [ "subgraph_count", List.length subgraphs |> Dyn.int ]);
  [%expect {| { subgraph_count = 1 } |}];
  let subgraph_node_count =
    List.hd subgraphs |> Option.get |> Vcs.Graph.of_subgraph |> Vcs.Graph.node_count
  in
  print_dyn (Dyn.Record [ "subgraph_node_count", subgraph_node_count |> Dyn.int ]);
  [%expect {| { subgraph_node_count = 6 } |}];
  (* Test leaves - the octopus merge should be the only leaf. *)
  print_dyn (Vcs.Graph.leaves graph |> Dyn.list Vcs.Graph.Node.to_dyn);
  [%expect {| [ "#5" ] |}];
  (* Test is_ancestor_or_equal through octopus merge. *)
  let node_of_rev rev = Vcs.Graph.find_rev graph ~rev |> Option.get in
  let is_ancestor ~ancestor ~descendant =
    print_dyn
      (Dyn.record
         [ ( "is_ancestor_or_equal"
           , Vcs.Graph.is_ancestor_or_equal
               graph
               ~ancestor:(node_of_rev ancestor)
               ~descendant:(node_of_rev descendant)
             |> Dyn.bool )
         ])
  in
  is_ancestor ~ancestor:revs.(0) ~descendant:oct;
  [%expect {| { is_ancestor_or_equal = true } |}];
  is_ancestor ~ancestor:revs.(4) ~descendant:oct;
  [%expect {| { is_ancestor_or_equal = true } |}];
  is_ancestor ~ancestor:oct ~descendant:revs.(0);
  [%expect {| { is_ancestor_or_equal = false } |}];
  is_ancestor ~ancestor:oct ~descendant:oct;
  [%expect {| { is_ancestor_or_equal = true } |}];
  (* Test descendance through octopus merge. *)
  let descendance r1 r2 =
    print_dyn
      (Vcs.Graph.descendance graph (node_of_rev r1) (node_of_rev r2)
       |> Vcs.Graph.Descendance.to_dyn)
  in
  descendance revs.(0) oct;
  [%expect {| Strict_ancestor |}];
  descendance oct revs.(0);
  [%expect {| Strict_descendant |}];
  descendance oct oct;
  [%expect {| Same_node |}];
  descendance revs.(1) revs.(3);
  [%expect {| Strict_ancestor |}];
  (* Test GCA with octopus merge. Add two children of the octopus merge. *)
  let child1 = Vcs.Mock_rev_gen.next mock_rev_gen in
  let child2 = Vcs.Mock_rev_gen.next mock_rev_gen in
  Vcs.Graph.add_nodes
    graph
    ~log:[ Line.commit ~rev:child1 ~parent:oct; Line.commit ~rev:child2 ~parent:oct ];
  print_dyn (Vcs.Graph.to_dyn graph);
  [%expect
    {|
    { nodes =
        [ ("#7",
           Commit
             { rev = "a10df8416f2f220ed41ac630e04ce0eca10df841"; parent = "#5" })
        ; ("#6",
           Commit
             { rev = "7ed4d629173cfd51910db866822b4ffc7ed4d629"; parent = "#5" })
        ; ("#5",
           Octopus_merge
             { rev = "5ef28c38bcaa95fe160c24835e478d0a5ef28c38"
             ; parent1 = "#0"
             ; parent2 = "#1"
             ; parent3 = "#2"
             ; parent4 = "#3"
             ; parent5 = "#4"
             })
        ; ("#4",
           Commit
             { rev = "e797f5f4f71cb1c58260feee65acea0ee797f5f4"; parent = "#3" })
        ; ("#3",
           Commit
             { rev = "e80940773fa5563bc1708976ce1c29f3e8094077"; parent = "#2" })
        ; ("#2",
           Commit
             { rev = "db529706776748aef99c04f4e71457e5db529706"; parent = "#1" })
        ; ("#1",
           Commit
             { rev = "a84ce8227bc12bf8e1bb8ca3b2a350b8a84ce822"; parent = "#0" })
        ; ("#0", Root { rev = "bfd32f3af3313cad34fd988e3135a891bfd32f3a" })
        ]
    ; revs =
        [ ("#7", "a10df8416f2f220ed41ac630e04ce0eca10df841")
        ; ("#6", "7ed4d629173cfd51910db866822b4ffc7ed4d629")
        ; ("#5", "5ef28c38bcaa95fe160c24835e478d0a5ef28c38")
        ; ("#4", "e797f5f4f71cb1c58260feee65acea0ee797f5f4")
        ; ("#3", "e80940773fa5563bc1708976ce1c29f3e8094077")
        ; ("#2", "db529706776748aef99c04f4e71457e5db529706")
        ; ("#1", "a84ce8227bc12bf8e1bb8ca3b2a350b8a84ce822")
        ; ("#0", "bfd32f3af3313cad34fd988e3135a891bfd32f3a")
        ]
    ; refs = []
    }
    |}];
  descendance child1 child2;
  [%expect {| Other |}];
  let gca revs =
    let nodes = List.map revs ~f:node_of_rev in
    print_dyn
      (Vcs.Graph.greatest_common_ancestors graph ~nodes |> Dyn.list Vcs.Graph.Node.to_dyn)
  in
  (* GCA of two children of the octopus merge is the octopus merge. *)
  gca [ child1; child2 ];
  [%expect {| [ "#5" ] |}];
  (* GCA of a child and an ancestor of the octopus merge. *)
  gca [ child1; revs.(2) ];
  [%expect {| [ "#2" ] |}];
  (* GCA of octopus merge and one of its parents. *)
  gca [ oct; revs.(2) ];
  [%expect {| [ "#2" ] |}];
  (* GCA of a child and the octopus merge itself. *)
  gca [ child1; oct ];
  [%expect {| [ "#5" ] |}];
  ()
;;

module Mock : sig
  type t

  val create : Vcs.Graph.t -> t
  val node : t -> rev:Vcs.Rev.t -> Vcs.Graph.Node.t
  val tag : t -> rev:Vcs.Rev.t -> string -> unit
  val root : t -> Vcs.Rev.t
  val commit : t -> parent:Vcs.Rev.t -> Vcs.Rev.t
  val merge : t -> parent1:Vcs.Rev.t -> parent2:Vcs.Rev.t -> Vcs.Rev.t
  val print_gcas : t -> revs:Vcs.Rev.t list -> unit
end = struct
  type t =
    { graph : Vcs.Graph.t
    ; mock_rev_gen : Vcs.Mock_rev_gen.t
    }

  let create graph = { graph; mock_rev_gen = Vcs.Mock_rev_gen.create ~name:"test-graph" }
  let rev t = Vcs.Mock_rev_gen.next t.mock_rev_gen
  let node t ~rev = Vcs.Graph.find_rev t.graph ~rev |> Option.get

  let tag t ~rev tag_name =
    Vcs.Graph.set_ref t.graph ~rev ~ref_kind:(Tag { tag_name = Vcs.Tag_name.v tag_name })
  ;;

  let root t =
    let rev = rev t in
    Vcs.Graph.add_nodes t.graph ~log:[ Line.root ~rev ];
    rev
  ;;

  let commit t ~parent =
    let rev = rev t in
    Vcs.Graph.add_nodes t.graph ~log:[ Line.commit ~rev ~parent ];
    rev
  ;;

  let merge t ~parent1 ~parent2 =
    let rev = rev t in
    Vcs.Graph.add_nodes t.graph ~log:[ Line.merge ~rev ~parent1 ~parent2 ];
    rev
  ;;

  let print_gcas t ~revs =
    let gcas =
      Vcs.Graph.greatest_common_ancestors
        t.graph
        ~nodes:(List.map revs ~f:(fun rev -> node t ~rev))
      |> List.map ~f:(fun node ->
        match Vcs.Graph.node_refs t.graph ~node with
        | ref :: _ -> Vcs.Ref_kind.to_string ref
        | [] ->
          (* This branch is kept for debug if it is executed by mistake but we
             shouldn't exercise this case since this makes the tests results
             harder to understand. *)
          (Vcs.Graph.rev t.graph ~node |> Vcs.Rev.to_string) [@coverage off])
    in
    print_dyn (Dyn.record [ "gcas", gcas |> Dyn.list Dyn.string ])
  ;;
end

let%expect_test "greatest_common_ancestors" =
  let graph = Vcs.Graph.create () in
  let t = Mock.create graph in
  let gcas revs = Mock.print_gcas t ~revs in
  gcas [];
  [%expect {| { gcas = [] } |}];
  let root1 = Mock.root t in
  Mock.tag t ~rev:root1 "root1";
  gcas [ root1 ];
  [%expect {| { gcas = [ "refs/tags/root1" ] } |}];
  let r1 = Mock.commit t ~parent:root1 in
  Mock.tag t ~rev:r1 "r1";
  gcas [ r1 ];
  [%expect {| { gcas = [ "refs/tags/r1" ] } |}];
  gcas [ root1; r1 ];
  [%expect {| { gcas = [ "refs/tags/root1" ] } |}];
  let m1 = Mock.merge t ~parent1:root1 ~parent2:r1 in
  Mock.tag t ~rev:m1 "m1";
  gcas [ m1 ];
  [%expect {| { gcas = [ "refs/tags/m1" ] } |}];
  gcas [ root1; m1 ];
  [%expect {| { gcas = [ "refs/tags/root1" ] } |}];
  gcas [ r1; m1 ];
  [%expect {| { gcas = [ "refs/tags/r1" ] } |}];
  gcas [ root1; r1; m1 ];
  [%expect {| { gcas = [ "refs/tags/root1" ] } |}];
  let root2 = Mock.root t in
  Mock.tag t ~rev:root2 "root2";
  gcas [ root1; root2 ];
  [%expect {| { gcas = [] } |}];
  gcas [ r1; root2 ];
  [%expect {| { gcas = [] } |}];
  let r2 =
    List.fold (List.init ~len:10 ~f:ignore) ~init:r1 ~f:(fun parent () ->
      Mock.commit t ~parent)
  in
  let r3 =
    List.fold (List.init ~len:10 ~f:ignore) ~init:m1 ~f:(fun parent () ->
      Mock.commit t ~parent)
  in
  gcas [ r2; r3 ];
  [%expect {| { gcas = [ "refs/tags/r1" ] } |}];
  (* A criss-cross merge. *)
  let alice = Mock.commit t ~parent:r1 in
  Mock.tag t ~rev:alice "alice";
  let bob = Mock.commit t ~parent:r1 in
  Mock.tag t ~rev:bob "bob";
  let alice_merge = Mock.merge t ~parent1:alice ~parent2:bob in
  let bob_merge = Mock.merge t ~parent1:bob ~parent2:alice in
  let alice_continue = Mock.commit t ~parent:alice_merge in
  let bob_continue = Mock.commit t ~parent:bob_merge in
  gcas [ alice_continue; bob_continue ];
  [%expect {| { gcas = [ "refs/tags/alice"; "refs/tags/bob" ] } |}];
  ()
;;

let%expect_test "gca - regression" =
  let graph = Vcs.Graph.create () in
  let t = Mock.create graph in
  let gcas revs = Mock.print_gcas t ~revs in
  let root = Mock.root t in
  Mock.tag t ~rev:root "root";
  let c1 = Mock.commit t ~parent:root in
  let m = Mock.commit t ~parent:root in
  Mock.tag t ~rev:m "middle";
  let c2 = Mock.commit t ~parent:root in
  let left = Mock.merge t ~parent1:c1 ~parent2:m in
  let right = Mock.merge t ~parent1:m ~parent2:c2 in
  gcas [ left; right ];
  [%expect {| { gcas = [ "refs/tags/middle" ] } |}];
  gcas [ c1; right ];
  [%expect {| { gcas = [ "refs/tags/root" ] } |}];
  gcas [ left; c2 ];
  [%expect {| { gcas = [ "refs/tags/root" ] } |}];
  gcas [ c1; c2 ];
  [%expect {| { gcas = [ "refs/tags/root" ] } |}];
  ()
;;

(* In this part of the test, we want to monitor that the interface exposed by
   [Vcs.Graph] is sufficient to write some algorithm on git graphs. As an example
   here, we are implementing from the user land a function that returns the set
   of nodes that are ancestors of a given node. *)

let ancestors graph node =
  let visited = Bitv.create (Vcs.Graph.node_count graph) false in
  let rec loop to_visit =
    match to_visit with
    | [] -> ()
    | node :: to_visit ->
      let node_index = Vcs.Graph.node_index node in
      if Bitv.get visited node_index
      then loop to_visit
      else (
        Bitv.set visited node_index true;
        loop (Vcs.Graph.prepend_parents graph ~node ~prepend_to:to_visit))
  in
  loop [ node ];
  Bitv.foldi_right
    (fun i visited set ->
       if visited then Vcs.Graph.get_node_exn graph ~index:i :: set else set)
    visited
    []
;;

let%expect_test "debug graph" =
  (* If needed, sexp_of_t should show helpful indices for nodes. *)
  let graph = Vcs.Graph.create () in
  let t = Mock.create graph in
  let r0 = Mock.root t in
  let c1 = Mock.commit t ~parent:r0 in
  let c2 = Mock.commit t ~parent:r0 in
  let m1 = Mock.merge t ~parent1:c1 ~parent2:c2 in
  let c4 = Mock.commit t ~parent:m1 in
  let r1 = Mock.root t in
  let m2 = Mock.merge t ~parent1:c4 ~parent2:r1 in
  Vcs.Graph.set_refs
    graph
    ~refs:
      [ { rev = c1
        ; ref_kind =
            Remote_branch { remote_branch_name = Vcs.Remote_branch_name.v "origin/main" }
        }
      ; { rev = c4; ref_kind = Tag { tag_name = Vcs.Tag_name.v "0.1.0" } }
      ; { rev = c4; ref_kind = Local_branch { branch_name = Vcs.Branch_name.main } }
      ];
  print_dyn (graph |> Vcs.Graph.to_dyn);
  [%expect
    {|
    { nodes =
        [ ("#6",
           Merge
             { rev = "ed2a9ed9f5d7bee45156ba272651656ced2a9ed9"
             ; parent1 = "#4"
             ; parent2 = "#5"
             })
        ; ("#5", Root { rev = "b155b82523d24ea82eb0ad45a5e89adcb155b825" })
        ; ("#4",
           Commit
             { rev = "7216231cd107946841cc3eebe5da287b7216231c"; parent = "#3" })
        ; ("#3",
           Merge
             { rev = "9a81fba7a18f740120f1141b1ed109bb9a81fba7"
             ; parent1 = "#1"
             ; parent2 = "#2"
             })
        ; ("#2",
           Commit
             { rev = "5deb4aaec51a75ef58765038b7c20b3f5deb4aae"; parent = "#0" })
        ; ("#1",
           Commit
             { rev = "f453b802f640c6888df978c712057d17f453b802"; parent = "#0" })
        ; ("#0", Root { rev = "5cd237e9598b11065c344d1eb33bc8c15cd237e9" })
        ]
    ; revs =
        [ ("#6", "ed2a9ed9f5d7bee45156ba272651656ced2a9ed9")
        ; ("#5", "b155b82523d24ea82eb0ad45a5e89adcb155b825")
        ; ("#4", "7216231cd107946841cc3eebe5da287b7216231c")
        ; ("#3", "9a81fba7a18f740120f1141b1ed109bb9a81fba7")
        ; ("#2", "5deb4aaec51a75ef58765038b7c20b3f5deb4aae")
        ; ("#1", "f453b802f640c6888df978c712057d17f453b802")
        ; ("#0", "5cd237e9598b11065c344d1eb33bc8c15cd237e9")
        ]
    ; refs =
        [ ("#4",
           [ Local_branch { branch_name = "main" }; Tag { tag_name = "0.1.0" } ])
        ; ("#1",
           [ Remote_branch
               { remote_branch_name =
                   { remote_name = "origin"; branch_name = "main" }
               }
           ])
        ]
    }
    |}];
  (* node_count *)
  print_dyn (Dyn.record [ "node_count", Vcs.Graph.node_count graph |> Dyn.int ]);
  [%expect {| { node_count = 7 } |}];
  (* node_kind *)
  let node_kind rev =
    let node = Mock.node t ~rev in
    print_dyn (Vcs.Graph.node_kind graph ~node |> Vcs.Graph.Node_kind.to_dyn)
  in
  node_kind r0;
  [%expect {| Root { rev = "5cd237e9598b11065c344d1eb33bc8c15cd237e9" } |}];
  node_kind c1;
  [%expect
    {| Commit { rev = "f453b802f640c6888df978c712057d17f453b802"; parent = "#0" } |}];
  node_kind m1;
  [%expect
    {|
    Merge
      { rev = "9a81fba7a18f740120f1141b1ed109bb9a81fba7"
      ; parent1 = "#1"
      ; parent2 = "#2"
      }
    |}];
  node_kind c4;
  [%expect
    {| Commit { rev = "7216231cd107946841cc3eebe5da287b7216231c"; parent = "#3" } |}];
  node_kind m2;
  [%expect
    {|
    Merge
      { rev = "ed2a9ed9f5d7bee45156ba272651656ced2a9ed9"
      ; parent1 = "#4"
      ; parent2 = "#5"
      }
    |}];
  (* ancestors *)
  let print_ancestors rev =
    print_dyn (ancestors graph (Mock.node t ~rev) |> Dyn.list Vcs.Graph.Node.to_dyn)
  in
  print_ancestors r0;
  [%expect {| [ "#0" ] |}];
  print_ancestors c1;
  [%expect {| [ "#0"; "#1" ] |}];
  print_ancestors c2;
  [%expect {| [ "#0"; "#2" ] |}];
  print_ancestors m1;
  [%expect {| [ "#0"; "#1"; "#2"; "#3" ] |}];
  print_ancestors c4;
  [%expect {| [ "#0"; "#1"; "#2"; "#3"; "#4" ] |}];
  (* Low level int indexing. *)
  let node_index node = print_dyn (Vcs.Graph.node_index node |> Dyn.int) in
  node_index (Mock.node t ~rev:r0);
  [%expect {| 0 |}];
  node_index (Mock.node t ~rev:c4);
  [%expect {| 4 |}];
  print_s (Vcs.Graph.get_node_exn graph ~index:0 |> Vcs.Graph.Node.sexp_of_t);
  [%expect {| #0 |}];
  let get_node_exn index =
    print_dyn (Vcs.Graph.get_node_exn graph ~index |> Vcs.Graph.Node.to_dyn)
  in
  get_node_exn 0;
  [%expect {| "#0" |}];
  get_node_exn 4;
  [%expect {| "#4" |}];
  require_does_raise (fun () -> get_node_exn 50);
  [%expect {| ("Node index out of bounds.", { index = 50; node_count = 7 }) |}];
  require_does_raise (fun () -> get_node_exn (-1));
  [%expect {| ("Node index out of bounds.", { index = -1; node_count = 7 }) |}];
  (* Here we monitor for a regression of a bug where [set_ref] would not
     properly update pre-existing bindings. *)
  let upstream =
    Vcs.Ref_kind.Remote_branch
      { remote_branch_name = Vcs.Remote_branch_name.v "origin/main" }
  in
  let show_upstream () =
    print_dyn
      (Vcs.Graph.find_ref graph ~ref_kind:upstream |> Dyn.option Vcs.Graph.Node.to_dyn)
  in
  show_upstream ();
  [%expect {| Some "#1" |}];
  (* We are now simulating that we pushed [main] and thus upstream [origin/main]
     has advanced to [r4]. *)
  Vcs.Graph.set_ref graph ~rev:c4 ~ref_kind:upstream;
  show_upstream ();
  [%expect {| Some "#4" |}];
  let show_refs rev =
    print_dyn
      (Vcs.Graph.node_refs graph ~node:(Mock.node t ~rev) |> Dyn.list Vcs.Ref_kind.to_dyn)
  in
  (* There are no longer any refs pointing to [r1]. *)
  show_refs c1;
  [%expect {| [] |}];
  (* Both [main] and [origin/main] now point to [r4]. *)
  show_refs c4;
  [%expect
    {|
    [ Local_branch { branch_name = "main" }
    ; Remote_branch
        { remote_branch_name = { remote_name = "origin"; branch_name = "main" } }
    ; Tag { tag_name = "0.1.0" }
    ]
    |}];
  print_dyn (Vcs.Graph.refs graph |> Vcs.Refs.to_dyn);
  [%expect
    {|
    [ { rev = "7216231cd107946841cc3eebe5da287b7216231c"
      ; ref_kind = Local_branch { branch_name = "main" }
      }
    ; { rev = "7216231cd107946841cc3eebe5da287b7216231c"
      ; ref_kind =
          Remote_branch
            { remote_branch_name =
                { remote_name = "origin"; branch_name = "main" }
            }
      }
    ; { rev = "7216231cd107946841cc3eebe5da287b7216231c"
      ; ref_kind = Tag { tag_name = "0.1.0" }
      }
    ]
    |}];
  print_dyn (graph |> Vcs.Graph.to_dyn);
  [%expect
    {|
    { nodes =
        [ ("#6",
           Merge
             { rev = "ed2a9ed9f5d7bee45156ba272651656ced2a9ed9"
             ; parent1 = "#4"
             ; parent2 = "#5"
             })
        ; ("#5", Root { rev = "b155b82523d24ea82eb0ad45a5e89adcb155b825" })
        ; ("#4",
           Commit
             { rev = "7216231cd107946841cc3eebe5da287b7216231c"; parent = "#3" })
        ; ("#3",
           Merge
             { rev = "9a81fba7a18f740120f1141b1ed109bb9a81fba7"
             ; parent1 = "#1"
             ; parent2 = "#2"
             })
        ; ("#2",
           Commit
             { rev = "5deb4aaec51a75ef58765038b7c20b3f5deb4aae"; parent = "#0" })
        ; ("#1",
           Commit
             { rev = "f453b802f640c6888df978c712057d17f453b802"; parent = "#0" })
        ; ("#0", Root { rev = "5cd237e9598b11065c344d1eb33bc8c15cd237e9" })
        ]
    ; revs =
        [ ("#6", "ed2a9ed9f5d7bee45156ba272651656ced2a9ed9")
        ; ("#5", "b155b82523d24ea82eb0ad45a5e89adcb155b825")
        ; ("#4", "7216231cd107946841cc3eebe5da287b7216231c")
        ; ("#3", "9a81fba7a18f740120f1141b1ed109bb9a81fba7")
        ; ("#2", "5deb4aaec51a75ef58765038b7c20b3f5deb4aae")
        ; ("#1", "f453b802f640c6888df978c712057d17f453b802")
        ; ("#0", "5cd237e9598b11065c344d1eb33bc8c15cd237e9")
        ]
    ; refs =
        [ ("#4",
           [ Local_branch { branch_name = "main" }
           ; Remote_branch
               { remote_branch_name =
                   { remote_name = "origin"; branch_name = "main" }
               }
           ; Tag { tag_name = "0.1.0" }
           ])
        ]
    }
    |}];
  (* We also test a case where [set_ref] leaves at least one ref at the previous
     location. *)
  let custom_A = Vcs.Ref_kind.Other { name = "custom-A" } in
  Vcs.Graph.set_ref graph ~rev:r0 ~ref_kind:custom_A;
  Vcs.Graph.set_ref graph ~rev:r0 ~ref_kind:(Other { name = "custom-B" });
  show_refs r0;
  [%expect {| [ Other { name = "custom-A" }; Other { name = "custom-B" } ] |}];
  Vcs.Graph.set_ref graph ~rev:c1 ~ref_kind:custom_A;
  show_refs r0;
  [%expect {| [ Other { name = "custom-B" } ] |}];
  show_refs c1;
  [%expect {| [ Other { name = "custom-A" } ] |}];
  ()
;;
