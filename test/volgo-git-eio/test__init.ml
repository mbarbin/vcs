(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "init" =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Volgo_git_eio.create ~env in
  let path = Filename.temp_dir ~temp_dir:(Unix.getcwd ()) "vcs" "test" in
  let repo_root =
    Eio.Switch.on_release sw (fun () ->
      Eio.Path.rmtree Eio.Path.(Eio.Stdenv.fs env / path));
    Vcs_test_helpers.init vcs ~path:(Absolute_path.v path)
  in
  require_equal
    (module Absolute_path)
    (Absolute_path.v path)
    (Vcs.Repo_root.to_absolute_path repo_root);
  [%expect {||}];
  ()
;;
