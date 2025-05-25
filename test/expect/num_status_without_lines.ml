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

(* This test shows a case where [git diff --numstat] doesn't give you numbers
   for insertions and deletions. *)

let%expect_test "num stat without lines" =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Volgo_git_eio.create ~env in
  let repo_root = Volgo_test_helpers.init_temp_repo ~env ~sw ~vcs in
  let commit_file ~path ~file_contents =
    Vcs.save_file
      vcs
      ~path:(Vcs.Repo_root.append repo_root path)
      ~file_contents:(Vcs.File_contents.create file_contents);
    Vcs.add vcs ~repo_root ~path;
    Vcs.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "_")
  in
  let hello_file = Vcs.Path_in_repo.v "hello.txt" in
  let rev1 = commit_file ~path:hello_file ~file_contents:"Hello World!\n" in
  print_s
    [%sexp
      (Vcs.Or_error.show_file_at_rev vcs ~repo_root ~rev:rev1 ~path:hello_file
       : [ `Present of Vcs.File_contents.t | `Absent ] Or_error.t)];
  [%expect {| (Ok (Present "Hello World!\n")) |}];
  let file1 = Vcs.Path_in_repo.v "file1.txt" in
  let rev2 = commit_file ~path:file1 ~file_contents:"file1" in
  let rev3 =
    commit_file
      ~path:hello_file
      ~file_contents:"Hello World!\nFollowed by an added line\n"
  in
  let rev4 = commit_file ~path:(Vcs.Path_in_repo.v "binary-file") ~file_contents:"\x00" in
  let print_status ~src ~dst =
    let num_status = Vcs.num_status vcs ~repo_root ~changed:(Between { src; dst }) in
    print_s [%sexp (num_status : Vcs.Num_status.t)]
  in
  print_status ~src:rev1 ~dst:rev2;
  [%expect
    {|
    ((
      (key (One_file file1.txt))
      (num_stat (
        Num_lines_in_diff (
          (insertions 1)
          (deletions  0)))))) |}];
  print_status ~src:rev2 ~dst:rev3;
  [%expect
    {|
    ((
      (key (One_file hello.txt))
      (num_stat (
        Num_lines_in_diff (
          (insertions 1)
          (deletions  0)))))) |}];
  print_status ~src:rev3 ~dst:rev4;
  [%expect {| (((key (One_file binary-file)) (num_stat Binary_file))) |}];
  print_status ~src:rev1 ~dst:rev4;
  [%expect
    {|
    (((key (One_file binary-file)) (num_stat Binary_file))
     ((key (One_file file1.txt))
      (num_stat (
        Num_lines_in_diff (
          (insertions 1)
          (deletions  0)))))
     ((key (One_file hello.txt))
      (num_stat (
        Num_lines_in_diff (
          (insertions 1)
          (deletions  0)))))) |}];
  ()
;;
