(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* This is a simple test to make sure we can initialize a repo and commit a
   file, and verify the mock rev mapping, in a purely blocking fashion. *)

let%expect_test "hello commit" =
  let vcs = Volgo_hg_unix.create () in
  let mock_revs = Vcs.Mock_revs.create () in
  let temp_dir =
    let cwd = Unix.getcwd () in
    Filename.temp_dir ~temp_dir:cwd "vcs_test" "" |> Absolute_path.v
  in
  let repo_root = Vcs.init vcs ~path:temp_dir in
  let hello_file = Vcs.Path_in_repo.v "hello.txt" in
  Vcs.save_file
    vcs
    ~path:(Vcs.Repo_root.append repo_root hello_file)
    ~file_contents:(Vcs.File_contents.create "Hello World!\n");
  let file_contents =
    Vcs.load_file vcs ~path:(Vcs.Repo_root.append repo_root hello_file)
  in
  print_string (Vcs.File_contents.to_string file_contents);
  [%expect {| Hello World! |}];
  Vcs.add vcs ~repo_root ~path:hello_file;
  let rev =
    Vcs.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "hello commit")
  in
  let mock_rev = Vcs.Mock_revs.to_mock mock_revs ~rev in
  print_dyn (mock_rev |> Vcs.Rev.to_dyn);
  [%expect {| "1185512b92d612b25613f2e5b473e5231185512b" |}];
  let output =
    Vcs.hg
      vcs
      ~repo_root
      ~args:
        (List.concat
           [ [ "cat"; Vcs.Path_in_repo.to_string hello_file ]
           ; [ "-r"; Vcs.Rev.to_string rev ]
           ])
      ~f:Vcs.Hg.exit0_and_stdout
  in
  print_endline output;
  [%expect {| Hello World! |}];
  ()
;;
