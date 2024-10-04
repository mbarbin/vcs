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

(* Test Vcs using the raising interface. *)

let%expect_test "find_enclosing_repo_root" =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Vcs_git_eio.create ~env in
  let repo_root = Vcs_test_helpers.init_temp_repo ~env ~sw ~vcs in
  (* Find the root from the root itself. *)
  let () =
    match
      Vcs.find_enclosing_git_repo_root
        vcs
        ~from:(repo_root |> Vcs.Repo_root.to_absolute_path)
    with
    | None -> assert false
    | Some repo_root2 ->
      require_equal [%here] (module Vcs.Repo_root) repo_root repo_root2;
      [%expect {||}]
  in
  (* Find the root from a subdirectory. *)
  let () =
    let subdir = Vcs.Repo_root.append repo_root (Vcs.Path_in_repo.v "path/in/repo") in
    Eio.Path.mkdirs
      ~exists_ok:true
      ~perm:0o777
      Eio.Path.(Eio.Stdenv.fs env / Absolute_path.to_string subdir);
    match Vcs.find_enclosing_git_repo_root vcs ~from:subdir with
    | None -> assert false
    | Some repo_root2 ->
      require_equal [%here] (module Vcs.Repo_root) repo_root repo_root2;
      [%expect {||}]
  in
  (* Stop before root (e.g. in a Mercurial repo). *)
  let () =
    let stop_at = Vcs.Repo_root.append repo_root (Vcs.Path_in_repo.v "path") in
    let subdir = Absolute_path.append stop_at (Relative_path.v "other/dir") in
    Eio.Path.mkdirs
      ~exists_ok:true
      ~perm:0o777
      Eio.Path.(Eio.Stdenv.fs env / Absolute_path.to_string subdir);
    (match
       Vcs.find_enclosing_repo_root
         vcs
         ~from:subdir
         ~store:[ Fpart.dot_git; Fpart.dot_hg ]
     with
     | None -> assert false
     | Some (`Store store, repo_root2) ->
       require_equal [%here] (module Fpart) store Fpart.dot_git;
       require_equal [%here] (module Vcs.Repo_root) repo_root repo_root2;
       [%expect {||}]);
    Eio.Path.save
      ~create:(`Or_truncate 0o666)
      Eio.Path.(Eio.Stdenv.fs env / Absolute_path.to_string stop_at / ".hg")
      "";
    match Vcs.find_enclosing_repo_root vcs ~from:subdir ~store:[ Fpart.dot_hg ] with
    | None -> assert false
    | Some (`Store store, repo_root2) ->
      require_equal [%here] (module Fpart) store Fpart.dot_hg;
      require_equal
        [%here]
        (module Vcs.Repo_root)
        (Vcs.Repo_root.of_absolute_path stop_at)
        repo_root2;
      [%expect {||}]
  in
  (* Not found. This one is a bit more tricky to test because when running in
     the dune environment, we are inside a Git repo. *)
  let () =
    (match Vcs.find_enclosing_git_repo_root vcs ~from:Absolute_path.root with
     | Some _ -> assert false
     | None -> ());
    [%expect {||}]
  in
  ()
;;
