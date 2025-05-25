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

let%expect_test "base int hash" =
  (* In this test we monitor the hashes of some int values using [Base].

     We note here that we would not have expected [Base.Int.hash] to sometimes
     return negative values, nor encounter cases where [Base.Int.hash_fold_t]
     applied to an empty state returns a result that differs from that of
     [Base.Int.hash]. *)
  let test i =
    let h = Base.Int.hash i in
    let h2 = Base.Hash.run Base.Int.hash_fold_t i in
    print_s [%sexp (i : int), (h : int), (h2 : int), (h = h2 : bool)]
  in
  List.iter ~f:test [ 0; 1; 2; 4; 5; -123456789 ];
  [%expect
    {|
    (0 4316648529147585864 1058613066 false)
    (1 -2609136240614377266 129913994 false)
    (2 4005111014598772340 462777137 false)
    (4 -1213116315786261967 607293368 false)
    (5 -3822126110415902464 648017920 false)
    (-123456789 -547221948126359607 131804527 false)
    |}];
  ()
;;

let%expect_test "stdlib int hash" =
  (* Using [Stdlib.Int.hash] the hash values are always positive. *)
  let test i =
    let h = Stdlib.Int.hash i in
    let h2 = Stdlib.Int.seeded_hash 0 i in
    print_s [%sexp (i : int), (h : int), (h2 : int), (h = h2 : bool)]
  in
  List.iter ~f:test [ 0; 1; 2; 4; 5; -123456789 ];
  [%expect
    {|
    (0 129913994 129913994 true)
    (1 883721435 883721435 true)
    (2 648017920 648017920 true)
    (4 127382775 127382775 true)
    (5 378313623 378313623 true)
    (-123456789 470621265 470621265 true)
    |}];
  ()
;;

let%expect_test "node hash" =
  let mock_rev_gen = Vcs.Mock_rev_gen.create ~name:"test-graph" in
  let rev () = Vcs.Mock_rev_gen.next mock_rev_gen in
  let graph = Vcs.Graph.create () in
  let node ~rev = Vcs.Graph.find_rev graph ~rev |> Option.value_exn ~here:[%here] in
  let root () =
    let rev = rev () in
    Vcs.Graph.add_nodes graph ~log:[ Vcs.Log.Line.Root { rev } ];
    node ~rev, rev
  in
  let commit ~parent =
    let rev = rev () in
    Vcs.Graph.add_nodes graph ~log:[ Vcs.Log.Line.Commit { rev; parent } ];
    node ~rev, rev
  in
  let merge ~parent1 ~parent2 =
    let rev = rev () in
    Vcs.Graph.add_nodes graph ~log:[ Vcs.Log.Line.Merge { rev; parent1; parent2 } ];
    node ~rev, rev
  in
  let n1, r1 = root () in
  let n2, r2 = commit ~parent:r1 in
  let n3, r3 = commit ~parent:r1 in
  let nm1, m1 = merge ~parent1:r2 ~parent2:r3 in
  let n4, r4 = commit ~parent:m1 in
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
  Hash_test.run
    (module Vcs.Graph.Node)
    (module Volgo_base.Vcs.Graph.Node)
    [ n1; n2; n3; n4; nm1 ];
  [%expect
    {|
    (((value #0))
     ((stdlib_hash   129913994)
      (vcs_hash      129913994)
      (vcs_base_hash 4316648529147585864)))
    (((value #0)
      (seed  0))
     ((stdlib_hash   129913994)
      (vcs_hash      129913994)
      (vcs_base_hash 1058613066)))
    (((value #0)
      (seed  42))
     ((stdlib_hash   269061838)
      (vcs_hash      269061838)
      (vcs_base_hash 992140660)))
    (((value #1))
     ((stdlib_hash   883721435)
      (vcs_hash      883721435)
      (vcs_base_hash -2609136240614377266)))
    (((value #1)
      (seed  0))
     ((stdlib_hash   883721435)
      (vcs_hash      883721435)
      (vcs_base_hash 129913994)))
    (((value #1)
      (seed  42))
     ((stdlib_hash   166027884)
      (vcs_hash      166027884)
      (vcs_base_hash 269061838)))
    (((value #2))
     ((stdlib_hash   648017920)
      (vcs_hash      648017920)
      (vcs_base_hash 4005111014598772340)))
    (((value #2)
      (seed  0))
     ((stdlib_hash   648017920)
      (vcs_hash      648017920)
      (vcs_base_hash 462777137)))
    (((value #2)
      (seed  42))
     ((stdlib_hash   1013383106)
      (vcs_hash      1013383106)
      (vcs_base_hash 1005547790)))
    (((value #4))
     ((stdlib_hash   127382775)
      (vcs_hash      127382775)
      (vcs_base_hash -1213116315786261967)))
    (((value #4)
      (seed  0))
     ((stdlib_hash   127382775)
      (vcs_hash      127382775)
      (vcs_base_hash 607293368)))
    (((value #4)
      (seed  42))
     ((stdlib_hash   688167720)
      (vcs_hash      688167720)
      (vcs_base_hash 1062720725)))
    (((value #3))
     ((stdlib_hash   152507349)
      (vcs_hash      152507349)
      (vcs_base_hash 1396078460937419741)))
    (((value #3)
      (seed  0))
     ((stdlib_hash   152507349)
      (vcs_hash      152507349)
      (vcs_base_hash 883721435)))
    (((value #3)
      (seed  42))
     ((stdlib_hash   97476682)
      (vcs_hash      97476682)
      (vcs_base_hash 166027884)))
    |}];
  ()
;;

let%expect_test "descendance-hash" =
  Hash_test.run
    (module Vcs.Graph.Descendance)
    (module Volgo_base.Vcs.Graph.Descendance)
    Vcs.Graph.Descendance.all;
  [%expect
    {|
    (((value Same_node))
     ((stdlib_hash   129913994)
      (vcs_hash      129913994)
      (vcs_base_hash 1058613066)))
    (((value Same_node)
      (seed  0))
     ((stdlib_hash   129913994)
      (vcs_hash      129913994)
      (vcs_base_hash 1058613066)))
    (((value Same_node)
      (seed  42))
     ((stdlib_hash   269061838)
      (vcs_hash      269061838)
      (vcs_base_hash 992140660)))
    (((value Strict_ancestor))
     ((stdlib_hash   883721435)
      (vcs_hash      883721435)
      (vcs_base_hash 129913994)))
    (((value Strict_ancestor)
      (seed  0))
     ((stdlib_hash   883721435)
      (vcs_hash      883721435)
      (vcs_base_hash 129913994)))
    (((value Strict_ancestor)
      (seed  42))
     ((stdlib_hash   166027884)
      (vcs_hash      166027884)
      (vcs_base_hash 269061838)))
    (((value Strict_descendant))
     ((stdlib_hash   648017920)
      (vcs_hash      648017920)
      (vcs_base_hash 462777137)))
    (((value Strict_descendant)
      (seed  0))
     ((stdlib_hash   648017920)
      (vcs_hash      648017920)
      (vcs_base_hash 462777137)))
    (((value Strict_descendant)
      (seed  42))
     ((stdlib_hash   1013383106)
      (vcs_hash      1013383106)
      (vcs_base_hash 1005547790)))
    (((value Other))
     ((stdlib_hash   152507349)
      (vcs_hash      152507349)
      (vcs_base_hash 883721435)))
    (((value Other)
      (seed  0))
     ((stdlib_hash   152507349)
      (vcs_hash      152507349)
      (vcs_base_hash 883721435)))
    (((value Other)
      (seed  42))
     ((stdlib_hash   97476682)
      (vcs_hash      97476682)
      (vcs_base_hash 166027884)))
    |}];
  ()
;;
