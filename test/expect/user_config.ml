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

let commit_file vcs ~repo_root ~path ~file_contents ~commit_message =
  Vcs.save_file vcs ~path:(Vcs.Repo_root.append repo_root path) ~file_contents;
  Vcs.add vcs ~repo_root ~path;
  Vcs.commit vcs ~repo_root ~commit_message
;;

let show_commit_metadata vcs ~repo_root ~rev =
  Vcs.git
    vcs
    ~repo_root
    ~args:[ "log"; "-n"; "1"; "--pretty=format:\"%an <%ae>\""; Vcs.Rev.to_string rev ]
    ~f:Vcs.Git.exit0_and_stdout
  |> print_endline
;;

let%expect_test "set-user-config" =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Volgo_git_eio.create ~env in
  let repo_root = Volgo_test_helpers.init_temp_repo ~env ~sw ~vcs in
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
  show_commit_metadata vcs ~repo_root ~rev;
  [%expect {| "Test User <test@example.com>" |}];
  Vcs.set_user_name vcs ~repo_root ~user_name:(Vcs.User_name.v "Other User");
  Vcs.set_user_email vcs ~repo_root ~user_email:(Vcs.User_email.v "other@other-user.org");
  let rev =
    commit_file
      vcs
      ~repo_root
      ~path:hello_file
      ~file_contents:(Vcs.File_contents.create "Hello World!\nWe're adding a new line!")
      ~commit_message:(Vcs.Commit_message.v "hello commit")
  in
  show_commit_metadata vcs ~repo_root ~rev;
  [%expect {| "Other User <other@other-user.org>" |}];
  let () =
    Vcs.Result.set_user_name vcs ~repo_root ~user_name:(Vcs.User_name.v "Third User")
    |> Stdlib.Result.get_ok
  in
  let () =
    Vcs.Result.set_user_email
      vcs
      ~repo_root
      ~user_email:(Vcs.User_email.v "third@third-user.org")
    |> Stdlib.Result.get_ok
  in
  let rev =
    commit_file
      vcs
      ~repo_root
      ~path:hello_file
      ~file_contents:
        (Vcs.File_contents.create "Hello World!\nWe're adding an even better new line!")
      ~commit_message:(Vcs.Commit_message.v "a commit by a third user")
  in
  show_commit_metadata vcs ~repo_root ~rev;
  [%expect {| "Third User <third@third-user.org>" |}];
  ()
;;
