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

(* This test shows how to lookup revision from various reference kinds (branch,
   tag, etc). It does so using different ways supported by the API.

   The test also contains a characterization of a behavior of [git rev-parse]
   happening when its input is ambiguous, and document why we ended up removing
   [Vcs.rev_parse] from the API. *)

let commit_file vcs ~repo_root ~path ~file_contents ~commit_message =
  Vcs.save_file vcs ~path:(Vcs.Repo_root.append repo_root path) ~file_contents;
  Vcs.add vcs ~repo_root ~path;
  Vcs.commit vcs ~repo_root ~commit_message
;;

let%expect_test "find ref" =
  Eio_main.run
  @@ fun env ->
  With_temp_repo.run ~env
  @@ fun ~vcs ~repo_root ->
  let mock_revs = Vcs.Mock_revs.create () in
  let hello_file = Vcs.Path_in_repo.v "hello.txt" in
  let rev =
    commit_file
      vcs
      ~repo_root
      ~path:hello_file
      ~file_contents:(Vcs.File_contents.create "Hello World!")
      ~commit_message:(Vcs.Commit_message.v "hello commit")
  in
  let mock_rev = Vcs.Mock_revs.to_mock mock_revs ~rev in
  print_s [%sexp (mock_rev : Vcs.Rev.t)];
  [%expect {| 1185512b92d612b25613f2e5b473e5231185512b |}];
  (* The head is the revision of the latest commit. *)
  let head = Vcs.current_revision vcs ~repo_root in
  require_equal
    [%here]
    (module Vcs.Rev)
    (Vcs.Mock_revs.to_mock mock_revs ~rev:head)
    mock_rev;
  (* Making sure the default branch name is deterministic. *)
  Vcs.rename_current_branch vcs ~repo_root ~to_:Vcs.Branch_name.main;
  let current_branch = Vcs.current_branch vcs ~repo_root in
  print_s [%sexp (current_branch : Vcs.Branch_name.t)];
  [%expect {| main |}];
  (* We'll now create 2 diverging branches. *)
  let create_branch branch_name =
    Vcs.git vcs ~repo_root ~args:[ "branch"; branch_name ] ~f:Vcs.Git.exit0
    |> Or_error.ok_exn
  in
  List.iter [ "branch1"; "branch2" ] ~f:create_branch;
  let commit_change branch =
    Vcs.git vcs ~repo_root ~args:[ "checkout"; branch ] ~f:Vcs.Git.exit0
    |> Or_error.ok_exn;
    commit_file
      vcs
      ~repo_root
      ~path:hello_file
      ~file_contents:(Vcs.File_contents.create (Printf.sprintf "Hello World @ %s" branch))
      ~commit_message:(Vcs.Commit_message.v ("hello " ^ branch))
  in
  let branch1_head = commit_change "branch1" in
  let branch2_head = commit_change "branch2" in
  print_s
    [%sexp
      { branch1 = (Vcs.Mock_revs.to_mock mock_revs ~rev:branch1_head : Vcs.Rev.t)
      ; branch2 = (Vcs.Mock_revs.to_mock mock_revs ~rev:branch2_head : Vcs.Rev.t)
      }];
  [%expect
    {|
    ((branch1 dd5aabd331a75b90cd61725223964e47dd5aabd3)
     (branch2 f452a6f91ee8f448bd58bbd0f3330675f452a6f9))
    |}];
  (* Let's create 2 tags. On purpose, we create a confusing tag whose name
     duplicates the name of a branch with a distinct head. This allows
     monitoring that the vcs api allows for finding the correct revisions based
     on references provided by the user. *)
  let create_tag tag rev =
    Vcs.git vcs ~repo_root ~args:[ "tag"; tag; Vcs.Rev.to_string rev ] ~f:Vcs.Git.exit0
    |> Or_error.ok_exn
  in
  create_tag "tag1" branch1_head;
  (* Tag "branch1" points to [branch2_head]. This isn't a typo, we purposely
     create an ambiguity regarding what the rev-parse argument "branch1" means.
     Is it the tag, or the branch? *)
  create_tag "branch1" branch2_head;
  (* We show first how to do reference lookup using [Vcs.refs]. *)
  let refs = Vcs.refs vcs ~repo_root |> Vcs.Refs.to_map in
  let lookup ~(find_exn : Vcs.Ref_kind.t -> 'a) =
    [%sexp
      { branch1 =
          (find_exn (Local_branch { branch_name = Vcs.Branch_name.v "branch1" })
           : Vcs.Rev.t)
      ; branch2 =
          (find_exn (Local_branch { branch_name = Vcs.Branch_name.v "branch2" })
           : Vcs.Rev.t)
      ; tag1 = (find_exn (Tag { tag_name = Vcs.Tag_name.v "tag1" }) : Vcs.Rev.t)
      ; tag2 = (find_exn (Tag { tag_name = Vcs.Tag_name.v "branch1" }) : Vcs.Rev.t)
      }]
  in
  let sexp1 =
    let find_exn arg =
      let rev = Map.find_exn refs arg in
      Vcs.Mock_revs.to_mock mock_revs ~rev
    in
    lookup ~find_exn
  in
  print_s sexp1;
  [%expect
    {|
    ((branch1 dd5aabd331a75b90cd61725223964e47dd5aabd3)
     (branch2 f452a6f91ee8f448bd58bbd0f3330675f452a6f9)
     (tag1    dd5aabd331a75b90cd61725223964e47dd5aabd3)
     (tag2    f452a6f91ee8f448bd58bbd0f3330675f452a6f9))
    |}];
  (* Next we do the same lookups, this time using [Vcs.Tree.find_ref], and
     verify that we find the same results. *)
  let tree = Vcs.tree vcs ~repo_root in
  let sexp2 =
    let find_exn ref_kind =
      match Vcs.Tree.find_ref tree ~ref_kind with
      | Some node -> Vcs.Mock_revs.to_mock mock_revs ~rev:(Vcs.Tree.Node.rev tree node)
      | None -> assert false
    in
    lookup ~find_exn
  in
  require_equal [%here] (module Sexp) sexp1 sexp2;
  [%expect {||}];
  (* Finally, we characterize some issue with [rev_parse].

     Without more information to be able to distinguish between a tag and a
     branch with the same name, the rev-parse command complains that the input
     is ambiguous, and we do not want to rely on the actual choice that it
     makes.

     This is the reason why we ended up removing [rev_parse] from the vcs api, and replaced it
     with the 2 technics shown above:

     1. [Vcs.Tree.find_ref] and
     2. [Vcs.refs |> Vcs.Refs.to_map]. *)
  let ambiguous_rev =
    Vcs.git
      vcs
      ~repo_root
      ~args:[ "rev-parse"; "--verify"; "branch1^{commit}" ]
      ~f:(fun ({ Vcs.Git.Output.stdout = _; stderr; exit_code = _ } as output) ->
        print_endline stderr;
        Vcs.Git.exit0_and_stdout output)
    |> Or_error.ok_exn
    |> String.strip
    |> Vcs.Rev.v
  in
  [%expect {| warning: refname 'branch1' is ambiguous. |}];
  let branch1_rev =
    Map.find_exn refs (Local_branch { branch_name = Vcs.Branch_name.v "branch1" })
  in
  let tag_rev = Map.find_exn refs (Tag { tag_name = Vcs.Tag_name.v "branch1" }) in
  require
    [%here]
    (Vcs.Rev.equal ambiguous_rev branch1_rev || Vcs.Rev.equal ambiguous_rev tag_rev);
  ()
;;
