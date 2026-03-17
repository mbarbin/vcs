(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* This is a simple test to make sure we can initialize a repo and commit a
   file, and verify the mock rev mapping, in a purely blocking fashion. *)

let%expect_test "hello commit" =
  let vcs = Volgo_git_unix.create () in
  let mock_revs = Vcs.Mock_revs.create () in
  let cwd = Unix.getcwd () |> Absolute_path.v in
  let repo_root = Vcs_test_helpers.init vcs ~path:cwd in
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
  print_s
    (Vcs.Result.show_file_at_rev
       vcs
       ~repo_root
       ~rev:(Vcs.Mock_revs.of_mock mock_revs ~mock_rev |> Option.get)
       ~path:hello_file
     |> Vcs.Result.sexp_of_t Vcs.File_shown_at_rev.sexp_of_t);
  [%expect {| (Ok (Present "Hello World!\n")) |}];
  print_s
    (Vcs.Result.show_file_at_rev vcs ~repo_root ~rev ~path:hello_file
     |> Vcs.Result.sexp_of_t Vcs.File_shown_at_rev.sexp_of_t);
  [%expect {| (Ok (Present "Hello World!\n")) |}];
  ()
;;

let%expect_test "read_dir" =
  let vcs = Volgo_git_unix.create () in
  let read_dir dir = print_dyn (Vcs.read_dir vcs ~dir |> Dyn.list Fsegment.to_dyn) in
  let cwd = Unix.getcwd () in
  let dir = Filename.temp_dir ~temp_dir:cwd "vcs_test" "" |> Absolute_path.v in
  let save_file file file_contents =
    Vcs.save_file
      vcs
      ~path:(Absolute_path.extend dir (Fsegment.v file))
      ~file_contents:(Vcs.File_contents.create file_contents)
  in
  read_dir dir;
  [%expect {| [] |}];
  save_file "hello.txt" "Hello World!\n";
  [%expect {||}];
  read_dir dir;
  [%expect {| [ "hello.txt" ] |}];
  save_file "foo" "Hello Foo!\n";
  [%expect {||}];
  read_dir dir;
  [%expect {| [ "foo"; "hello.txt" ] |}];
  let () =
    match Vcs.read_dir vcs ~dir:(Absolute_path.v "/invalid") with
    | (_ : Fsegment.t list) -> assert false
    | exception Err.E err -> print_s (err |> Err.sexp_of_t)
  in
  [%expect
    {|
    ((context (Vcs.read_dir (dir /invalid)))
     (error (Sys_error "/invalid: No such file or directory")))
    |}];
  ()
;;
