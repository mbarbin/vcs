(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
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

(* This is a simple test to make sure we can initialize a repo and commit a
   file, and verify the mock rev mapping. *)

let%expect_test "hello commit" =
  Miou_unix.run
  @@ fun () ->
  let vcs = Vcs_git_miou.create () in
  let mock_revs = Vcs.Mock_revs.create () in
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
  print_s
    [%sexp
      (Vcs.read_dir vcs ~dir:(Vcs.Repo_root.to_absolute_path repo_root) : Fsegment.t list)];
  [%expect {| (.git hello.txt) |}];
  Vcs.add vcs ~repo_root ~path:hello_file;
  let rev =
    Vcs.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "hello commit")
  in
  let mock_rev = Vcs.Mock_revs.to_mock mock_revs ~rev in
  print_s [%sexp (mock_rev : Vcs.Rev.t)];
  [%expect {| 1185512b92d612b25613f2e5b473e5231185512b |}];
  print_s
    [%sexp
      (Vcs.Result.show_file_at_rev
         vcs
         ~repo_root
         ~rev:(Vcs.Mock_revs.of_mock mock_revs ~mock_rev |> Option.value_exn ~here:[%here])
         ~path:hello_file
       : [ `Present of Vcs.File_contents.t | `Absent ] Vcs.Result.t)];
  [%expect {| (Ok (Present "Hello World!")) |}];
  print_s
    [%sexp
      (Vcs.Result.show_file_at_rev vcs ~repo_root ~rev ~path:hello_file
       : [ `Present of Vcs.File_contents.t | `Absent ] Vcs.Result.t)];
  [%expect {| (Ok (Present "Hello World!")) |}];
  (* Using [Vcs] from within cooperative [Miou.async] constructs. *)
  let p1 =
    Miou.async (fun () -> [%sexp (Vcs.current_branch vcs ~repo_root : Vcs.Branch_name.t)])
  in
  let p2 =
    Miou.async (fun () ->
      [%sexp
        (Vcs.ls_files vcs ~repo_root ~below:Vcs.Path_in_repo.root
         : Vcs.Path_in_repo.t list)])
  in
  Miou.await_all [ p1; p2 ]
  |> List.iter ~f:(function
    | Ok sexp -> print_s sexp
    | Error exn -> raise exn [@coverage off]);
  [%expect
    {|
    main
    (hello.txt)
    |}];
  ()
;;
