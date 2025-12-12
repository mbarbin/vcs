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

(* Since [Volgo_hg_eio] uses the exact same implementation than [Volgo_git_eio]
   for file system operations, we do not need to test it exhaustively. We simply
   exercise a simple code path. *)

let%expect_test "read_dir" =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Volgo_hg_eio.create ~env in
  let path = Stdlib.Filename.temp_dir ~temp_dir:(Unix.getcwd ()) "vcs" "test" in
  Eio.Switch.on_release sw (fun () -> Eio.Path.rmtree Eio.Path.(Eio.Stdenv.fs env / path));
  let repo_root = Vcs.init vcs ~path:(Absolute_path.v path) in
  let dir = Vcs.Repo_root.to_absolute_path repo_root in
  let read_dir dir = print_s [%sexp (Vcs.read_dir vcs ~dir : Fsegment.t list)] in
  read_dir dir;
  [%expect {| (.hg) |}];
  ()
;;
