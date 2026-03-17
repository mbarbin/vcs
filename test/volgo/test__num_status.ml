(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "parse_exn" =
  Eio_main.run
  @@ fun env ->
  let path = Eio.Path.(Eio.Stdenv.fs env / "super-master-mind.num-status") in
  let contents = Eio.Path.load path in
  let lines = String.split_lines contents in
  let num_status = Volgo_git_backend.Num_status.parse_lines_exn ~lines in
  ignore (num_status : Vcs.Num_status.t);
  [%expect {||}];
  ()
;;
