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

(* This test shows cases where [git diff --name-status] shows you changes in
   file type. *)

module Unix = UnixLabels

let%expect_test "name status with type change" =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Volgo_git_eio.create ~env in
  let repo_root = Vcs_test_helpers.init_temp_repo ~env ~sw ~vcs in
  let save_file ~path ~file_contents =
    Vcs.save_file
      vcs
      ~path:(Vcs.Repo_root.append repo_root path)
      ~file_contents:(Vcs.File_contents.create file_contents)
  in
  let commit_file ~path =
    Vcs.add vcs ~repo_root ~path;
    Vcs.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "_")
  in
  let hello_file = Vcs.Path_in_repo.v "hello.txt" in
  save_file ~path:hello_file ~file_contents:"Hello World!\n";
  let rev1 = commit_file ~path:hello_file in
  let hello2_file = Vcs.Path_in_repo.v "hello2.txt" in
  save_file ~path:hello2_file ~file_contents:"Hello World!\nAnother line.\nAnd another.\n";
  let rev2 = commit_file ~path:hello2_file in
  print_s
    [%sexp
      (Vcs.show_file_at_rev vcs ~repo_root ~rev:rev2 ~path:hello_file
       : [ `Present of Vcs.File_contents.t | `Absent ])];
  [%expect {| (Present "Hello World!\n") |}];
  let print_num_status ~src ~dst =
    let num_status = Vcs.num_status vcs ~repo_root ~changed:(Between { src; dst }) in
    print_s [%sexp (num_status : Vcs.Num_status.t)]
  in
  let print_name_status ~src ~dst =
    let name_status = Vcs.name_status vcs ~repo_root ~changed:(Between { src; dst }) in
    print_s [%sexp (name_status : Vcs.Name_status.t)]
  in
  print_name_status ~src:rev1 ~dst:rev2;
  [%expect {| ((Added hello2.txt)) |}];
  (* Now let's change the file2 to be a symlink to the file 1 instead. *)
  Unix.unlink (Vcs.Repo_root.append repo_root hello2_file |> Absolute_path.to_string);
  Unix.symlink
    ?to_dir:None
    ~src:(Vcs.Repo_root.append repo_root hello_file |> Absolute_path.to_string)
    ~dst:(Vcs.Repo_root.append repo_root hello2_file |> Absolute_path.to_string);
  let rev3 = commit_file ~path:hello2_file in
  print_name_status ~src:rev2 ~dst:rev3;
  [%expect {| ((Modified hello2.txt)) |}];
  print_num_status ~src:rev2 ~dst:rev3;
  [%expect
    {|
    (((key (One_file hello2.txt))
      (num_stat (Num_lines_in_diff (insertions 1) (deletions 3)))))
    |}];
  (* Let's make it a regular file again, and further change its contents. *)
  Unix.unlink (Vcs.Repo_root.append repo_root hello2_file |> Absolute_path.to_string);
  save_file ~path:hello2_file ~file_contents:"Hello New Contents!\nHere are more lines!\n";
  let rev4 = commit_file ~path:hello2_file in
  (* Git reports this as a single 'T' change. *)
  print_name_status ~src:rev3 ~dst:rev4;
  [%expect {| ((Modified hello2.txt)) |}];
  (* Git reports this as a single 'T' change. *)
  print_num_status ~src:rev3 ~dst:rev4;
  [%expect
    {|
    (((key (One_file hello2.txt))
      (num_stat (Num_lines_in_diff (insertions 2) (deletions 1)))))
    |}];
  ()
;;
