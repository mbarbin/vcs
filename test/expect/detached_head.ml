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

(* This test shows cases where the repo is in a detached head state (when no
   branch is currently active). *)

let commit_file vcs ~repo_root ~path ~file_contents ~commit_message =
  Vcs.save_file vcs ~path:(Vcs.Repo_root.append repo_root path) ~file_contents;
  Vcs.add vcs ~repo_root ~path;
  Vcs.commit vcs ~repo_root ~commit_message
;;

let%expect_test "detached-head" =
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
  let current_branch_opt = Vcs.current_branch_opt vcs ~repo_root in
  print_dyn (current_branch_opt |> Dyn.option Vcs.Branch_name.to_dyn);
  [%expect {| Some "main" |}];
  Vcs.git vcs ~repo_root ~args:[ "switch"; "--detach"; "main" ] ~f:Vcs.Git.exit0;
  let () =
    match Vcs.Result.current_branch vcs ~repo_root with
    | Ok _ -> assert false
    | Error err ->
      print_s (Vcs_test_helpers.redact_sexp (Err.sexp_of_t err) ~fields:[ "repo_root" ])
  in
  [%expect
    {|
    ((context (Vcs.current_branch (repo_root <REDACTED>)))
     (error "Not currently on any branch."))
    |}];
  let current_branch_opt =
    Vcs.Result.current_branch_opt vcs ~repo_root |> Result.get_ok
  in
  print_dyn (current_branch_opt |> Dyn.option Vcs.Branch_name.to_dyn);
  [%expect {| None |}];
  ()
;;
