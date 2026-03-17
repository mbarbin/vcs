(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* This is a simple test to make sure we can initialize a repo and commit a
   file, and verify the mock rev mapping. *)

let%expect_test "hello commit" =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Volgo_git_eio.create ~env in
  let mock_revs = Vcs.Mock_revs.create () in
  let repo_root = Vcs_test_helpers.init_temp_repo ~env ~sw ~vcs in
  let hello_file = Vcs.Path_in_repo.v "hello.txt" in
  Vcs.save_file
    vcs
    ~path:(Vcs.Repo_root.append repo_root hello_file)
    ~file_contents:(Vcs.File_contents.create "Hello World!");
  Vcs.add vcs ~repo_root ~path:hello_file;
  let rev =
    Vcs.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "hello commit")
  in
  let mock_rev = Vcs.Mock_revs.to_mock mock_revs ~rev in
  print_dyn (mock_rev |> Vcs.Rev.to_dyn);
  [%expect {| "1185512b92d612b25613f2e5b473e5231185512b" |}];
  print_s
    (Vcs.Result.show_file_at_rev
       vcs
       ~repo_root
       ~rev:(Vcs.Mock_revs.of_mock mock_revs ~mock_rev |> Option.get)
       ~path:hello_file
     |> Vcs.Result.sexp_of_t Vcs.File_shown_at_rev.sexp_of_t);
  [%expect {| (Ok (Present "Hello World!")) |}];
  print_s
    (Vcs.Result.show_file_at_rev vcs ~repo_root ~rev ~path:hello_file
     |> Vcs.Result.sexp_of_t Vcs.File_shown_at_rev.sexp_of_t);
  [%expect {| (Ok (Present "Hello World!")) |}];
  ()
;;
