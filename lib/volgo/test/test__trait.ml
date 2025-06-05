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

let%expect_test "unimplemented" =
  (* We exercise below the methods of the unimplemented object, through its use
     as a vcs backend. This monitors the error messages, as well as testing that
     the context is indeed well propagated in case of an error. *)
  let repo_root = Vcs.Repo_root.v "/path/to/repo" in
  let vcs_obj = new Vcs.Trait.unimplemented in
  let vcs = Vcs.create vcs_obj in
  let mock_rev_gen = Vcs.Mock_rev_gen.create ~name:"test__trait" in
  let rev0 = Vcs.Mock_rev_gen.next mock_rev_gen in
  let rev1 = Vcs.Mock_rev_gen.next mock_rev_gen in
  let test f = require_does_raise [%here] f in
  (* add *)
  test (fun () -> Vcs.add vcs ~repo_root ~path:(Vcs.Path_in_repo.v "foo"));
  [%expect
    {|
    ((context (
       Vcs.add (
         (repo_root /path/to/repo)
         (path      foo))))
     (error
      "Trait [Vcs.Trait.add] method [add] is not available in this repository."))
    |}];
  (* branch *)
  test (fun () -> Vcs.rename_current_branch vcs ~repo_root ~to_:(Vcs.Branch_name.v "foo"));
  [%expect
    {|
    ((context (
       Vcs.rename_current_branch (
         (repo_root /path/to/repo)
         (to_       foo))))
     (error
      "Trait [Vcs.Trait.branch] method [rename_current_branch] is not available in this repository."))
    |}];
  (* commit *)
  test (fun () -> Vcs.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "_"));
  [%expect
    {|
    ((context (Vcs.commit ((repo_root /path/to/repo))))
     (error
      "Trait [Vcs.Trait.commit] method [commit] is not available in this repository."))
    |}];
  (* config *)
  test (fun () -> Vcs.set_user_name vcs ~repo_root ~user_name:(Vcs.User_name.v "user1"));
  [%expect
    {|
    ((context (
       Vcs.set_user_name (
         (repo_root /path/to/repo)
         (user_name user1))))
     (error
      "Trait [Vcs.Trait.config] method [set_user_name] is not available in this repository."))
    |}];
  test (fun () ->
    Vcs.set_user_email vcs ~repo_root ~user_email:(Vcs.User_email.v "user1@mail.com"));
  [%expect
    {|
    ((context (
       Vcs.set_user_email (
         (repo_root  /path/to/repo)
         (user_email user1@mail.com))))
     (error
      "Trait [Vcs.Trait.config] method [set_user_email] is not available in this repository."))
    |}];
  (* file_system *)
  test (fun () -> Vcs.load_file vcs ~path:(Absolute_path.v "/path/to/file"));
  [%expect
    {|
    ((context (Vcs.load_file ((path /path/to/file))))
     (error
      "Trait [Vcs.Trait.file_system] method [load_file] is not available in this repository."))
    |}];
  test (fun () ->
    Vcs.save_file
      vcs
      ~path:(Absolute_path.v "/path/to/file")
      ~file_contents:(Vcs.File_contents.create "Hello"));
  [%expect
    {|
    ((context (Vcs.save_file ((perms ()) (path /path/to/file))))
     (error
      "Trait [Vcs.Trait.file_system] method [save_file] is not available in this repository."))
    |}];
  test (fun () -> Vcs.read_dir vcs ~dir:(Absolute_path.v "/path/to/dir"));
  [%expect
    {|
    ((context (Vcs.read_dir ((dir /path/to/dir))))
     (error
      "Trait [Vcs.Trait.file_system] method [read_dir] is not available in this repository."))
    |}];
  (* git *)
  test (fun () -> Vcs.git vcs ~repo_root ~args:[ "status" ] ~f:Vcs.Git.exit0);
  [%expect
    {|
    ((context (Vcs.git ((repo_root /path/to/repo) (args (status)))))
     (error
      "Trait [Vcs.Trait.git] method [git] is not available in this repository."))
    |}];
  (* init *)
  test (fun () -> Vcs.init vcs ~path:(Absolute_path.v "/path/to/dir"));
  [%expect
    {|
    ((context (Vcs.init ((path /path/to/dir))))
     (error
      "Trait [Vcs.Trait.init] method [init] is not available in this repository."))
    |}];
  (* log *)
  test (fun () -> Vcs.log vcs ~repo_root);
  [%expect
    {|
    ((context (Vcs.log ((repo_root /path/to/repo))))
     (error
      "Trait [Vcs.Trait.log] method [all] is not available in this repository."))
    |}];
  (* ls_files *)
  test (fun () -> Vcs.ls_files vcs ~repo_root ~below:Vcs.Path_in_repo.root);
  [%expect
    {|
    ((context (
       Vcs.ls_files (
         (repo_root /path/to/repo)
         (below     ./))))
     (error
      "Trait [Vcs.Trait.ls_files] method [ls_files] is not available in this repository."))
    |}];
  (* name_status *)
  test (fun () ->
    Vcs.name_status vcs ~repo_root ~changed:(Between { src = rev0; dst = rev1 }));
  [%expect
    {|
    ((context (
       Vcs.name_status (
         (repo_root /path/to/repo)
         (changed (
           Between
           (src 3e8f3b8084fe4864ab5ecf955a8cf5093e8f3b80)
           (dst 8f2865699c137a14c65ae28b83fde96b8f286569))))))
     (error
      "Trait [Vcs.Trait.name_status] method [name_status] is not available in this repository."))
    |}];
  (* num_status *)
  test (fun () ->
    Vcs.num_status vcs ~repo_root ~changed:(Between { src = rev0; dst = rev1 }));
  [%expect
    {|
    ((context (
       Vcs.num_status (
         (repo_root /path/to/repo)
         (changed (
           Between
           (src 3e8f3b8084fe4864ab5ecf955a8cf5093e8f3b80)
           (dst 8f2865699c137a14c65ae28b83fde96b8f286569))))))
     (error
      "Trait [Vcs.Trait.num_status] method [num_status] is not available in this repository."))
    |}];
  (* refs *)
  test (fun () -> Vcs.refs vcs ~repo_root);
  [%expect
    {|
    ((context (Vcs.refs ((repo_root /path/to/repo))))
     (error
      "Trait [Vcs.Trait.refs] method [show_ref] is not available in this repository."))
    |}];
  (* rev_parse *)
  test (fun () -> Vcs.current_branch vcs ~repo_root);
  [%expect
    {|
    ((context (Vcs.current_branch ((repo_root /path/to/repo))))
     (error
      "Trait [Vcs.Trait.rev_parse] method [current_branch] is not available in this repository."))
    |}];
  test (fun () -> Vcs.current_revision vcs ~repo_root);
  [%expect
    {|
    ((context (Vcs.current_revision ((repo_root /path/to/repo))))
     (error
      "Trait [Vcs.Trait.rev_parse] method [current_revision] is not available in this repository."))
    |}];
  (* show *)
  test (fun () ->
    Vcs.show_file_at_rev vcs ~repo_root ~rev:rev0 ~path:(Vcs.Path_in_repo.v "foo"));
  [%expect
    {|
    ((context (
       Vcs.show_file_at_rev (
         (repo_root /path/to/repo)
         (rev       3e8f3b8084fe4864ab5ecf955a8cf5093e8f3b80)
         (path      foo))))
     (error
      "Trait [Vcs.Trait.show] method [show_file_at_rev] is not available in this repository."))
    |}];
  ()
;;
