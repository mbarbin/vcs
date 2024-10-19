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

let values =
  List.concat
    [ List.map Test__branch_name.values ~f:(fun branch_name ->
        Vcs.Ref_kind.Local_branch { branch_name })
    ; List.map Test__remote_branch_name.values ~f:(fun remote_branch_name ->
        Vcs.Ref_kind.Remote_branch { remote_branch_name })
    ; List.map Test__tag_name.values ~f:(fun tag_name -> Vcs.Ref_kind.Tag { tag_name })
    ; List.map ~f:(fun name -> Vcs.Ref_kind.Other { name }) [ "HEAD"; "MERGE_HEAD" ]
    ]
;;

let%expect_test "hash" =
  Hash_test.run (module Vcs.Ref_kind) (module Vcs_base.Vcs.Ref_kind) values;
  [%expect
    {|
    (((value (Local_branch (branch_name main))))
     ((stdlib_hash   29025240)
      (vcs_hash      29025240)
      (vcs_base_hash 94735605)))
    (((value (Local_branch (branch_name main))) (seed 0))
     ((stdlib_hash   29025240)
      (vcs_hash      29025240)
      (vcs_base_hash 94735605)))
    (((value (Local_branch (branch_name main))) (seed 42))
     ((stdlib_hash   830500646)
      (vcs_hash      830500646)
      (vcs_base_hash 770880661)))
    (((value (Local_branch (branch_name my-branch))))
     ((stdlib_hash   946168396)
      (vcs_hash      946168396)
      (vcs_base_hash 984439962)))
    (((value (Local_branch (branch_name my-branch))) (seed 0))
     ((stdlib_hash   946168396)
      (vcs_hash      946168396)
      (vcs_base_hash 984439962)))
    (((value (Local_branch (branch_name my-branch))) (seed 42))
     ((stdlib_hash   335838264)
      (vcs_hash      335838264)
      (vcs_base_hash 878689118)))
    (((
       value (
         Remote_branch (
           remote_branch_name (
             (remote_name origin)
             (branch_name main))))))
     ((stdlib_hash   258976199)
      (vcs_hash      258976199)
      (vcs_base_hash 242619430)))
    (((value (
        Remote_branch (
          remote_branch_name (
            (remote_name origin)
            (branch_name main)))))
      (seed 0))
     ((stdlib_hash   258976199)
      (vcs_hash      258976199)
      (vcs_base_hash 242619430)))
    (((value (
        Remote_branch (
          remote_branch_name (
            (remote_name origin)
            (branch_name main)))))
      (seed 42))
     ((stdlib_hash   343494517)
      (vcs_hash      343494517)
      (vcs_base_hash 999580363)))
    (((
       value (
         Remote_branch (
           remote_branch_name (
             (remote_name origin)
             (branch_name my-branch))))))
     ((stdlib_hash   397055407)
      (vcs_hash      397055407)
      (vcs_base_hash 276051467)))
    (((value (
        Remote_branch (
          remote_branch_name (
            (remote_name origin)
            (branch_name my-branch)))))
      (seed 0))
     ((stdlib_hash   397055407)
      (vcs_hash      397055407)
      (vcs_base_hash 276051467)))
    (((value (
        Remote_branch (
          remote_branch_name (
            (remote_name origin)
            (branch_name my-branch)))))
      (seed 42))
     ((stdlib_hash   181104236)
      (vcs_hash      181104236)
      (vcs_base_hash 918453922)))
    (((
       value (
         Remote_branch (
           remote_branch_name (
             (remote_name upstream)
             (branch_name main))))))
     ((stdlib_hash   359047634)
      (vcs_hash      359047634)
      (vcs_base_hash 718475039)))
    (((value (
        Remote_branch (
          remote_branch_name (
            (remote_name upstream)
            (branch_name main)))))
      (seed 0))
     ((stdlib_hash   359047634)
      (vcs_hash      359047634)
      (vcs_base_hash 718475039)))
    (((value (
        Remote_branch (
          remote_branch_name (
            (remote_name upstream)
            (branch_name main)))))
      (seed 42))
     ((stdlib_hash   969621201)
      (vcs_hash      969621201)
      (vcs_base_hash 409254382)))
    (((
       value (
         Remote_branch (
           remote_branch_name (
             (remote_name upstream)
             (branch_name my-branch))))))
     ((stdlib_hash   646234684)
      (vcs_hash      646234684)
      (vcs_base_hash 646359821)))
    (((value (
        Remote_branch (
          remote_branch_name (
            (remote_name upstream)
            (branch_name my-branch)))))
      (seed 0))
     ((stdlib_hash   646234684)
      (vcs_hash      646234684)
      (vcs_base_hash 646359821)))
    (((value (
        Remote_branch (
          remote_branch_name (
            (remote_name upstream)
            (branch_name my-branch)))))
      (seed 42))
     ((stdlib_hash   201067920)
      (vcs_hash      201067920)
      (vcs_base_hash 21348147)))
    (((value (Tag (tag_name my-tag))))
     ((stdlib_hash   93827037)
      (vcs_hash      93827037)
      (vcs_base_hash 217296416)))
    (((value (Tag (tag_name my-tag))) (seed 0))
     ((stdlib_hash   93827037)
      (vcs_hash      93827037)
      (vcs_base_hash 217296416)))
    (((value (Tag (tag_name my-tag))) (seed 42))
     ((stdlib_hash   130085576)
      (vcs_hash      130085576)
      (vcs_base_hash 889889237)))
    (((value (Tag (tag_name v0.0.1))))
     ((stdlib_hash   853378279)
      (vcs_hash      853378279)
      (vcs_base_hash 959412064)))
    (((value (Tag (tag_name v0.0.1))) (seed 0))
     ((stdlib_hash   853378279)
      (vcs_hash      853378279)
      (vcs_base_hash 959412064)))
    (((value (Tag (tag_name v0.0.1))) (seed 42))
     ((stdlib_hash   4011706)
      (vcs_hash      4011706)
      (vcs_base_hash 511371176)))
    (((value (Tag (tag_name 1.2))))
     ((stdlib_hash   368157373)
      (vcs_hash      368157373)
      (vcs_base_hash 91233646)))
    (((value (Tag (tag_name 1.2))) (seed 0))
     ((stdlib_hash   368157373)
      (vcs_hash      368157373)
      (vcs_base_hash 91233646)))
    (((value (Tag (tag_name 1.2))) (seed 42))
     ((stdlib_hash   224592090)
      (vcs_hash      224592090)
      (vcs_base_hash 737977122)))
    (((value (Other (name HEAD))))
     ((stdlib_hash   245238873)
      (vcs_hash      245238873)
      (vcs_base_hash 816863108)))
    (((value (Other (name HEAD))) (seed 0))
     ((stdlib_hash   245238873)
      (vcs_hash      245238873)
      (vcs_base_hash 816863108)))
    (((value (Other (name HEAD))) (seed 42))
     ((stdlib_hash   599545985)
      (vcs_hash      599545985)
      (vcs_base_hash 190479651)))
    (((value (Other (name MERGE_HEAD))))
     ((stdlib_hash   1068385555)
      (vcs_hash      1068385555)
      (vcs_base_hash 645534583)))
    (((value (Other (name MERGE_HEAD))) (seed 0))
     ((stdlib_hash   1068385555)
      (vcs_hash      1068385555)
      (vcs_base_hash 645534583)))
    (((value (Other (name MERGE_HEAD))) (seed 42))
     ((stdlib_hash   681314370)
      (vcs_hash      681314370)
      (vcs_base_hash 121079498)))
    |}];
  ()
;;
