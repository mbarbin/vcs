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

let find_ref ~refs ~ref_kind:arg =
  List.find_map
    (refs : Vcs.Refs.t)
    ~f:(fun { rev; ref_kind } -> Option.some_if (Vcs.Ref_kind.equal ref_kind arg) rev)
;;

let%expect_test "find ref" =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Volgo_git_eio.create ~env in
  let repo_root = Vcs_test_helpers.init_temp_repo ~env ~sw ~vcs in
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
  print_dyn (mock_rev |> Vcs.Rev.to_dyn);
  [%expect {| "1185512b92d612b25613f2e5b473e5231185512b" |}];
  (* The head is the revision of the latest commit. *)
  let head = Vcs.current_revision vcs ~repo_root in
  require_equal (module Vcs.Rev) (Vcs.Mock_revs.to_mock mock_revs ~rev:head) mock_rev;
  (* Making sure the default branch name is deterministic. *)
  Vcs.rename_current_branch vcs ~repo_root ~to_:Vcs.Branch_name.main;
  let current_branch = Vcs.current_branch vcs ~repo_root in
  print_dyn (current_branch |> Vcs.Branch_name.to_dyn);
  [%expect {| "main" |}];
  (* We'll now create 2 diverging branches. *)
  let create_branch branch_name =
    Vcs.git vcs ~repo_root ~args:[ "branch"; branch_name ] ~f:Vcs.Git.exit0
  in
  List.iter [ "branch1"; "branch2" ] ~f:create_branch;
  let commit_change branch =
    Vcs.git vcs ~repo_root ~args:[ "checkout"; branch ] ~f:Vcs.Git.exit0;
    commit_file
      vcs
      ~repo_root
      ~path:hello_file
      ~file_contents:(Vcs.File_contents.create (Printf.sprintf "Hello World @ %s" branch))
      ~commit_message:(Vcs.Commit_message.v ("hello " ^ branch))
  in
  let branch1_head = commit_change "branch1" in
  let branch2_head = commit_change "branch2" in
  print_dyn
    (Dyn.record
       [ "branch1", Vcs.Mock_revs.to_mock mock_revs ~rev:branch1_head |> Vcs.Rev.to_dyn
       ; "branch2", Vcs.Mock_revs.to_mock mock_revs ~rev:branch2_head |> Vcs.Rev.to_dyn
       ]);
  [%expect
    {|
    { branch1 = "dd5aabd331a75b90cd61725223964e47dd5aabd3"
    ; branch2 = "f452a6f91ee8f448bd58bbd0f3330675f452a6f9"
    }
    |}];
  (* Let's create 2 tags. On purpose, we create a confusing tag whose name
     duplicates the name of a branch with a distinct head. This allows
     monitoring that the vcs api allows for finding the correct revisions based
     on references provided by the user. *)
  let create_tag tag rev =
    Vcs.git vcs ~repo_root ~args:[ "tag"; tag; Vcs.Rev.to_string rev ] ~f:Vcs.Git.exit0
  in
  create_tag "tag1" branch1_head;
  (* Tag "branch1" points to [branch2_head]. This isn't a typo, we purposely
     create an ambiguity regarding what the rev-parse argument "branch1" means.
     Is it the tag, or the branch? *)
  create_tag "branch1" branch2_head;
  (* We show first how to do reference lookup using [Vcs.refs]. *)
  let refs = Vcs.refs vcs ~repo_root in
  let lookup ~(find_exn : Vcs.Ref_kind.t -> Vcs.Rev.t) =
    Dyn.record
      [ ( "branch1"
        , find_exn (Local_branch { branch_name = Vcs.Branch_name.v "branch1" })
          |> Vcs.Rev.to_dyn )
      ; ( "branch2"
        , find_exn (Local_branch { branch_name = Vcs.Branch_name.v "branch2" })
          |> Vcs.Rev.to_dyn )
      ; "tag1", find_exn (Tag { tag_name = Vcs.Tag_name.v "tag1" }) |> Vcs.Rev.to_dyn
      ; "tag2", find_exn (Tag { tag_name = Vcs.Tag_name.v "branch1" }) |> Vcs.Rev.to_dyn
      ]
  in
  let dyn1 =
    let find_exn ref_kind =
      let rev = find_ref ~refs ~ref_kind |> Option.get in
      Vcs.Mock_revs.to_mock mock_revs ~rev
    in
    lookup ~find_exn
  in
  print_dyn dyn1;
  [%expect
    {|
    { branch1 = "dd5aabd331a75b90cd61725223964e47dd5aabd3"
    ; branch2 = "f452a6f91ee8f448bd58bbd0f3330675f452a6f9"
    ; tag1 = "dd5aabd331a75b90cd61725223964e47dd5aabd3"
    ; tag2 = "f452a6f91ee8f448bd58bbd0f3330675f452a6f9"
    }
    |}];
  (* Next we do the same lookups, this time using [Vcs.Graph.find_ref], and
     verify that we find the same results. *)
  let graph = Vcs.graph vcs ~repo_root in
  let dyn2 =
    let find_exn ref_kind =
      match Vcs.Graph.find_ref graph ~ref_kind with
      | Some node -> Vcs.Mock_revs.to_mock mock_revs ~rev:(Vcs.Graph.rev graph ~node)
      | None -> assert false
    in
    lookup ~find_exn
  in
  require_equal (module Sexp) (Dyn.to_sexp dyn1) (Dyn.to_sexp dyn2);
  [%expect {||}];
  (* Finally, we characterize some issue with [rev_parse].

     Without more information to be able to distinguish between a tag and a
     branch with the same name, the rev-parse command complains that the input
     is ambiguous, and we do not want to rely on the actual choice that it
     makes.

     This is the reason why we ended up removing [rev_parse] from the vcs api,
     and replaced it with the 2 technics shown above:

     1. [Vcs.Graph.find_ref] and
     2. [Vcs.refs |> Vcs.Refs.to_map]. *)
  let ambiguous_rev =
    Vcs.git
      vcs
      ~repo_root
      ~args:[ "rev-parse"; "--verify"; "branch1^{commit}" ]
      ~f:(fun ({ exit_code = _; stdout = _; stderr } as output) ->
        print_endline stderr;
        Vcs.Git.exit0_and_stdout output)
    |> String.strip
    |> Vcs.Rev.v
  in
  [%expect {| warning: refname 'branch1' is ambiguous. |}];
  let branch1_rev =
    find_ref ~refs ~ref_kind:(Local_branch { branch_name = Vcs.Branch_name.v "branch1" })
    |> Option.get
  in
  let tag_rev =
    find_ref ~refs ~ref_kind:(Tag { tag_name = Vcs.Tag_name.v "branch1" }) |> Option.get
  in
  require
    (List.exists [ branch1_rev; tag_rev ] ~f:(fun rev -> Vcs.Rev.equal ambiguous_rev rev));
  ()
;;
