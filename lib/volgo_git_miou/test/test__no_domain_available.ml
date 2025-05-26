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

(* As explained in the documentation, [Vcs_git_miou] requires one extra domain
   to run the blocking calls to git. In this test we monitor what happens if
   there is no such domain available. *)

let%expect_test "domains:0" =
  Miou_unix.run ~domains:0
  @@ fun () ->
  let vcs = Volgo_git_miou.create () in
  require_does_raise [%here] (fun () ->
    let path = Stdlib.Filename.temp_dir ~temp_dir:(Unix.getcwd ()) "vcs" "test" in
    Vcs_test_helpers.init vcs ~path:(Absolute_path.v path));
  [%expect {| (Miou.No_domain_available) |}];
  ()
;;

(* In the next test, we look at a case where the call to git is itself run from
   within a call to [Miou.call] when there is no other domain available. This
   should be considered a programming error. *)

let%expect_test "domains:1" =
  Miou_unix.run ~domains:1
  @@ fun () ->
  let vcs = Volgo_git_miou.create () in
  let repo_root =
    let path = Stdlib.Filename.temp_dir ~temp_dir:(Unix.getcwd ()) "vcs" "test" in
    Vcs_test_helpers.init vcs ~path:(Absolute_path.v path)
  in
  let hello_file = Vcs.Path_in_repo.v "hello.txt" in
  Vcs.save_file
    vcs
    ~path:(Vcs.Repo_root.append repo_root hello_file)
    ~file_contents:(Vcs.File_contents.create "Hello World!");
  print_s
    [%sexp
      (Vcs.load_file vcs ~path:(Vcs.Repo_root.append repo_root hello_file)
       : Vcs.File_contents.t)];
  [%expect {| "Hello World!" |}];
  require_does_raise [%here] (fun () ->
    Miou.call (fun () ->
      Vcs.save_file
        vcs
        ~path:(Vcs.Repo_root.append repo_root hello_file)
        ~file_contents:(Vcs.File_contents.create "Hello World Again!"))
    |> Miou.await_exn);
  [%expect {| (Miou.No_domain_available) |}];
  ()
;;
