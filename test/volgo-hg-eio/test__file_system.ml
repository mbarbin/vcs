(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* Since [Volgo_hg_eio] uses the exact same implementation than [Volgo_git_eio]
   for file system operations, we do not need to test it exhaustively. We simply
   exercise a simple code path. *)

let%expect_test "read_dir" =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Volgo_hg_eio.create ~env in
  let path = Filename.temp_dir ~temp_dir:(Unix.getcwd ()) "vcs" "test" in
  Eio.Switch.on_release sw (fun () -> Eio.Path.rmtree Eio.Path.(Eio.Stdenv.fs env / path));
  let repo_root = Vcs.init vcs ~path:(Absolute_path.v path) in
  let dir = Vcs.Repo_root.to_absolute_path repo_root in
  let read_dir dir = print_dyn (Vcs.read_dir vcs ~dir |> Dyn.list Fsegment.to_dyn) in
  read_dir dir;
  [%expect {| [ ".hg" ] |}];
  ()
;;
