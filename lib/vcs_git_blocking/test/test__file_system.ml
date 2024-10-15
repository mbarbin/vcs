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

let%expect_test "read_dir" =
  let vcs = Vcs_git_blocking.create () in
  let read_dir dir = print_s [%sexp (Vcs.read_dir vcs ~dir : Fsegment.t list)] in
  let cwd = Unix.getcwd () in
  let dir = Stdlib.Filename.temp_dir ~temp_dir:cwd "vcs_test" "" |> Absolute_path.v in
  let save_file file file_contents =
    Vcs.save_file
      vcs
      ~path:(Absolute_path.extend dir (Fsegment.v file))
      ~file_contents:(Vcs.File_contents.create file_contents)
  in
  read_dir dir;
  [%expect {| () |}];
  save_file "hello.txt" "Hello World!\n";
  [%expect {||}];
  read_dir dir;
  [%expect {| (hello.txt) |}];
  save_file "foo" "Hello Foo!\n";
  [%expect {||}];
  read_dir dir;
  [%expect {| (foo hello.txt) |}];
  (* Below we redact the actual temporary directory because they make the tests
     non stable. We redact the error when it contains a non-stable path. *)
  let () =
    (* [Vcs.read_dir] errors out on non-existing directories. *)
    match Vcs.read_dir vcs ~dir:(Absolute_path.v "/non-existing") with
    | (_ : Fsegment.t list) -> assert false
    | exception Vcs.E err ->
      print_s (Vcs_test_helpers.redact_sexp (Vcs.Err.sexp_of_t err) ~fields:[ "dir" ])
  in
  [%expect
    {|
    ((steps ((Vcs.read_dir ((dir <REDACTED>)))))
     (error (Sys_error "/non-existing: No such file or directory")))
    |}];
  let () =
    (* [Vcs.read_dir] errors out when called on an existing file rather than a
       directory. *)
    let path = Absolute_path.extend dir (Fsegment.v "foo") in
    let file_exists = Stdlib.Sys.file_exists (Absolute_path.to_string path) in
    assert file_exists;
    print_s [%sexp { file_exists : bool }];
    [%expect {| ((file_exists true)) |}];
    match Vcs.read_dir vcs ~dir:path with
    | (_ : Fsegment.t list) -> assert false
    | exception Vcs.E err ->
      print_s
        (Vcs_test_helpers.redact_sexp (Vcs.Err.sexp_of_t err) ~fields:[ "dir"; "error" ])
  in
  [%expect {| ((steps ((Vcs.read_dir ((dir <REDACTED>))))) (error <REDACTED>)) |}];
  ()
;;
