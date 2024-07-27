(*******************************************************************************)
(*  Vcs - a versatile OCaml library for Git interaction                        *)
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

(* [super-master-mind.log] has been created by capturing the output of:

   {v
      $ git log --all --pretty=format:'%H %P'
   v}

   In this test we verify that we can parse this output. *)

let%expect_test "parse_exn" =
  Eio_main.run
  @@ fun env ->
  let path = Eio.Path.(Eio.Stdenv.fs env / "super-master-mind.log") in
  let contents = Eio.Path.load path in
  let lines = String.split_lines contents in
  let log = List.map lines ~f:(fun line -> Git_cli.Log.parse_log_line_exn ~line) in
  let roots = Vcs.Log.roots log in
  print_s [%sexp (roots : Vcs.Rev.t list)];
  [%expect
    {|
    (35760b109070be51b9deb61c8fdc79c0b2d9065d
     da46f0d60bfbb9dc9340e95f5625c10815c24af7) |}];
  let merge_count =
    List.count log ~f:(function
      | Merge _ -> true
      | Root _ | Commit _ -> false)
  in
  print_s [%sexp { merge_count : int }];
  [%expect {| ((merge_count 2)) |}];
  ()
;;

let%expect_test "invalid lines" =
  let test line =
    print_s [%sexp (Git_cli.Log.parse_log_line_exn ~line : Vcs.Log.Line.t)]
  in
  test "35760b109070be51b9deb61c8fdc79c0b2d9065d";
  [%expect {| (Root (rev 35760b109070be51b9deb61c8fdc79c0b2d9065d)) |}];
  test "35760b109070be51b9deb61c8fdc79c0b2d9065d ";
  [%expect {| (Root (rev 35760b109070be51b9deb61c8fdc79c0b2d9065d)) |}];
  test "35760b109070be51b9deb61c8fdc79c0b2d9065d  ";
  [%expect {| (Root (rev 35760b109070be51b9deb61c8fdc79c0b2d9065d)) |}];
  test "b6951031b698697eb05f414d1f34000bb171a694 3dd9b4627aaa36f76c3097f9f31172f481b9229f";
  [%expect
    {|
    (Commit
      (rev    b6951031b698697eb05f414d1f34000bb171a694)
      (parent 3dd9b4627aaa36f76c3097f9f31172f481b9229f)) |}];
  test
    "3bf5092cc55bff4c3ba546c771e17ab8d29cce65 aff8c9c8601e68a41a3bb695ea4a276e2446061f \
     d3a24cbfad0a681280ecfe021d40b69fb0b9c589";
  [%expect
    {|
    (Merge
      (rev     3bf5092cc55bff4c3ba546c771e17ab8d29cce65)
      (parent1 aff8c9c8601e68a41a3bb695ea4a276e2446061f)
      (parent2 d3a24cbfad0a681280ecfe021d40b69fb0b9c589)) |}];
  require_does_raise [%here] (fun () -> test "");
  [%expect {| ("Rev.of_string: invalid entry" "") |}];
  require_does_raise [%here] (fun () ->
    test
      "3bf5092cc55bff4c3ba546c771e17ab8d29cce65 aff8c9c8601e68a41a3bb695ea4a276e2446061f \
       d3a24cbfad0a681280ecfe021d40b69fb0b9c589 3509268b3f47a9e081bf11ac5e59f8b6eac6109b");
  [%expect
    {|
    ("Invalid log line"
     "3bf5092cc55bff4c3ba546c771e17ab8d29cce65 aff8c9c8601e68a41a3bb695ea4a276e2446061f d3a24cbfad0a681280ecfe021d40b69fb0b9c589 3509268b3f47a9e081bf11ac5e59f8b6eac6109b") |}];
  ()
;;
