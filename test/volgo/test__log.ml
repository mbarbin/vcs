(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* More tests for the [Vcs.Log] module can be found in
   [lib/volgo_git_backend/test/test__log.ml]. *)

let%expect_test "parse_exn" =
  Eio_main.run
  @@ fun env ->
  let path = Eio.Path.(Eio.Stdenv.fs env / "super-master-mind.log") in
  let contents = Eio.Path.load path in
  let lines = String.split_lines contents in
  let log =
    List.map lines ~f:(fun line -> Volgo_git_backend.Log.parse_log_line_exn ~line)
  in
  let roots = Vcs.Log.roots log in
  print_dyn (roots |> Dyn.list Vcs.Rev.to_dyn);
  [%expect
    {|
    [ "35760b109070be51b9deb61c8fdc79c0b2d9065d"
    ; "da46f0d60bfbb9dc9340e95f5625c10815c24af7"
    ]
    |}];
  ()
;;
