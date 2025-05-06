(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
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

(* In this test we verify that we can parse chosen outputs from the data directory. *)

let%expect_test "parse_exn - super-master-mind" =
  Eio_main.run
  @@ fun env ->
  let path = Eio.Path.(Eio.Stdenv.fs env / "super-master-mind.num-status") in
  let contents = Eio.Path.load path in
  let lines = String.split_lines contents in
  let num_status = Vcs_git_backend.Num_status.parse_lines_exn ~lines in
  print_s [%sexp (num_status : Vcs.Num_status.t)];
  [%expect
    {|
    (((key (One_file .github/workflows/ci.yml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 3)
          (deletions  2)))))
     ((key (One_file .github/workflows/deploy-odoc.yml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  28)))))
     ((key (One_file .vscode/settings.json))
      (num_stat (
        Num_lines_in_diff (
          (insertions 2)
          (deletions  0)))))
     ((key (One_file CHANGELOG.md))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  28)))))
     ((key (One_file CHANGES.md))
      (num_stat (
        Num_lines_in_diff (
          (insertions 54)
          (deletions  0)))))
     ((key (One_file CODE_OF_CONDUCT.md))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  128)))))
     ((key (One_file Makefile))
      (num_stat (
        Num_lines_in_diff (
          (insertions 4)
          (deletions  1)))))
     ((key (One_file README.md))
      (num_stat (
        Num_lines_in_diff (
          (insertions 63)
          (deletions  59)))))
     ((key (One_file bin/dune))
      (num_stat (
        Num_lines_in_diff (
          (insertions 2)
          (deletions  2)))))
     ((key (One_file bin/main.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 1)
          (deletions  1)))))
     ((key (One_file dune-project))
      (num_stat (
        Num_lines_in_diff (
          (insertions 72)
          (deletions  3)))))
     ((key (One_file lib/super_master_mind/src/code.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 11)
          (deletions  7)))))
     ((key (One_file lib/super_master_mind/src/code.mli))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  2)))))
     ((key (One_file lib/super_master_mind/src/codes.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  3)))))
     ((key (One_file lib/super_master_mind/src/codes.mli))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  2)))))
     ((key (One_file lib/super_master_mind/src/color.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 15)
          (deletions  6)))))
     ((key (One_file lib/super_master_mind/src/color.mli))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  2)))))
     ((key (One_file lib/super_master_mind/src/color_permutation.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 4)
          (deletions  5)))))
     ((key (One_file lib/super_master_mind/src/color_permutation.mli))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  2)))))
     ((key (One_file lib/super_master_mind/src/cue.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 4)
          (deletions  6)))))
     ((key (One_file lib/super_master_mind/src/cue.mli))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  2)))))
     ((key (One_file lib/super_master_mind/src/dune))
      (num_stat (
        Num_lines_in_diff (
          (insertions 18)
          (deletions  6)))))
     ((key (One_file lib/super_master_mind/src/example.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 1)
          (deletions  5)))))
     ((key (One_file lib/super_master_mind/src/example.mli))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  2)))))
     ((key (One_file lib/super_master_mind/src/game_dimensions.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 11)
          (deletions  5)))))
     ((key (One_file lib/super_master_mind/src/game_dimensions.mli))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  3)))))
     ((key (One_file lib/super_master_mind/src/guess.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 73)
          (deletions  44)))))
     ((key (One_file lib/super_master_mind/src/guess.mli))
      (num_stat (
        Num_lines_in_diff (
          (insertions 25)
          (deletions  5)))))
     ((key (One_file lib/super_master_mind/src/import/dune))
      (num_stat (
        Num_lines_in_diff (
          (insertions 9)
          (deletions  0)))))
     ((key (
        Two_files
        (src lib/super_master_mind/src/import.ml)
        (dst lib/super_master_mind/src/import/super_master_mind_import.ml)))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  2)))))
     ((key (
        Two_files
        (src lib/super_master_mind/src/import.mli)
        (dst lib/super_master_mind/src/import/super_master_mind_import.mli)))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  2)))))
     ((key (One_file lib/super_master_mind/src/kheap.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  3)))))
     ((key (One_file lib/super_master_mind/src/kheap.mli))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  2)))))
     ((key (One_file lib/super_master_mind/src/maker.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 3)
          (deletions  6)))))
     ((key (One_file lib/super_master_mind/src/maker.mli))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  2)))))
     ((key (One_file lib/super_master_mind/src/opening_book.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 48)
          (deletions  22)))))
     ((key (One_file lib/super_master_mind/src/opening_book.mli))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  2)))))
     ((key (One_file lib/super_master_mind/src/solver.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 1)
          (deletions  4)))))
     ((key (One_file lib/super_master_mind/src/solver.mli))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  2)))))
     ((key (One_file lib/super_master_mind/src/super_master_mind.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  2)))))
     ((key (One_file lib/super_master_mind/src/super_master_mind.mli))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  1)))))
     ((key (One_file lib/super_master_mind/src/task_pool.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  2)))))
     ((key (One_file lib/super_master_mind/src/task_pool.mli))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  2)))))
     ((key (One_file lib/super_master_mind/test/dune))
      (num_stat (
        Num_lines_in_diff (
          (insertions 18)
          (deletions  3)))))
     ((key (One_file lib/super_master_mind/test/test__code.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 85)
          (deletions  33)))))
     ((key (One_file lib/super_master_mind/test/test__codes.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 92)
          (deletions  31)))))
     ((key (One_file lib/super_master_mind/test/test__color.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 7)
          (deletions  7)))))
     ((key (One_file lib/super_master_mind/test/test__color_permutation.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 5)
          (deletions  11)))))
     ((key (One_file lib/super_master_mind/test/test__cue.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 50)
          (deletions  34)))))
     ((key (One_file lib/super_master_mind/test/test__example.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  3)))))
     ((key (One_file lib/super_master_mind/test/test__game_dimensions.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 9)
          (deletions  11)))))
     ((key (One_file lib/super_master_mind/test/test__guess.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 678)
          (deletions  278)))))
     ((key (One_file lib/super_master_mind/test/test__kheap.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  4)))))
     ((key (One_file lib/super_master_mind/test/test__mins.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 108)
          (deletions  64)))))
     ((key (One_file lib/super_master_mind/test/test__opening_book.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 9)
          (deletions  11)))))
     ((key (One_file super-master-mind.opam))
      (num_stat (
        Num_lines_in_diff (
          (insertions 32)
          (deletions  22)))))
     ((key (One_file test/maker.t))
      (num_stat (
        Num_lines_in_diff (
          (insertions 4)
          (deletions  5)))))) |}];
  ()
;;

let%expect_test "parse_exn - eio" =
  Eio_main.run
  @@ fun env ->
  let path = Eio.Path.(Eio.Stdenv.fs env / "eio.num-status") in
  let contents = Eio.Path.load path in
  let lines = String.split_lines contents in
  let num_status = Vcs_git_backend.Num_status.parse_lines_exn ~lines in
  print_s [%sexp (num_status : Vcs.Num_status.t)];
  [%expect
    {|
    (((key (One_file CHANGES.md))
      (num_stat (
        Num_lines_in_diff (
          (insertions 31)
          (deletions  0)))))
     ((key (One_file README.md))
      (num_stat (
        Num_lines_in_diff (
          (insertions 106)
          (deletions  20)))))
     ((key (One_file bench/main.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 13)
          (deletions  0)))))
     ((key (One_file doc/multicore.md))
      (num_stat (
        Num_lines_in_diff (
          (insertions 32)
          (deletions  9)))))
     ((key (One_file doc/traces/Makefile))
      (num_stat (
        Num_lines_in_diff (
          (insertions 1)
          (deletions  1)))))
     ((key (One_file doc/traces/multicore-posix.fxt)) (num_stat Binary_file))
     ((key (One_file doc/traces/multicore-posix.svg))
      (num_stat (
        Num_lines_in_diff (
          (insertions 1490)
          (deletions  0)))))
     ((key (One_file dune-project))
      (num_stat (
        Num_lines_in_diff (
          (insertions 5)
          (deletions  5)))))
     ((key (One_file eio.opam))
      (num_stat (
        Num_lines_in_diff (
          (insertions 1)
          (deletions  1)))))
     ((key (One_file eio_linux.opam))
      (num_stat (
        Num_lines_in_diff (
          (insertions 2)
          (deletions  2)))))
     ((key (One_file eio_main.opam))
      (num_stat (
        Num_lines_in_diff (
          (insertions 1)
          (deletions  1)))))
     ((key (One_file eio_posix.opam))
      (num_stat (
        Num_lines_in_diff (
          (insertions 1)
          (deletions  1)))))
     ((key (One_file lib_eio/pool.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 29)
          (deletions  9)))))
     ((key (One_file lib_eio/pool.mli))
      (num_stat (
        Num_lines_in_diff (
          (insertions 8)
          (deletions  2)))))
     ((key (One_file lib_eio_linux/dune))
      (num_stat (
        Num_lines_in_diff (
          (insertions 1)
          (deletions  1)))))
     ((key (One_file lib_eio_linux/eio_linux.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 10)
          (deletions  10)))))
     ((key (One_file lib_eio_linux/eio_linux.mli))
      (num_stat (
        Num_lines_in_diff (
          (insertions 1)
          (deletions  204)))))
     ((key (One_file lib_eio_linux/log.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 0)
          (deletions  2)))))
     ((key (One_file lib_eio_linux/low_level.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 8)
          (deletions  13)))))
     ((key (One_file lib_eio_linux/low_level.mli))
      (num_stat (
        Num_lines_in_diff (
          (insertions 242)
          (deletions  0)))))
     ((key (One_file lib_eio_linux/sched.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 7)
          (deletions  11)))))
     ((key (One_file lib_eio_linux/tests/dune))
      (num_stat (
        Num_lines_in_diff (
          (insertions 2)
          (deletions  2)))))
     ((key (One_file lib_eio_linux/tests/test.ml))
      (num_stat (
        Num_lines_in_diff (
          (insertions 5)
          (deletions  5)))))
     ((key (One_file tests/pool.md))
      (num_stat (
        Num_lines_in_diff (
          (insertions 31)
          (deletions  0)))))) |}];
  ()
;;

let%expect_test "parse_lines_exn" =
  let lines =
    [ ""
    ; "file"
    ; "A\tB"
    ; "A\tB\tC\tD"
    ; "A\tB\tC"
    ; "0\t1\tfile"
    ; "1985\t0\tfile1 => file2"
    ; "100\t5\ttmp/{dir1 => dir2}/file"
    ; "-\t-\tfile"
    ; "-\t10\tfile"
    ; "7\t-\tfile"
    ; "-2\t-10\tfile"
    ; "1985\t0\tfile1 => /tmp/file2"
    ]
  in
  List.iter lines ~f:(fun line ->
    let result =
      Or_error.try_with (fun () -> Vcs_git_backend.Num_status.parse_line_exn ~line)
    in
    print_s [%sexp (line : string), (result : Vcs.Num_status.Change.t Or_error.t)]);
  [%expect
    {|
    ("" (
      Error (
        (context (Vcs_git_backend.Num_status.parse_line_exn ((line ""))))
        (error "Unexpected output from git diff."))))
    (file (
      Error (
        (context (Vcs_git_backend.Num_status.parse_line_exn ((line file))))
        (error "Unexpected output from git diff."))))
    ("A\tB" (
      Error (
        (context (Vcs_git_backend.Num_status.parse_line_exn ((line "A\tB"))))
        (error "Unexpected output from git diff."))))
    ("A\tB\tC\tD" (
      Error (
        (context (Vcs_git_backend.Num_status.parse_line_exn ((line "A\tB\tC\tD"))))
        (error "Unexpected output from git diff."))))
    ("A\tB\tC" (
      Error (
        (context (Vcs_git_backend.Num_status.parse_line_exn ((line "A\tB\tC"))))
        (error (
          "Unexpected output from git diff." (
            (insertions (Other A))
            (deletions  (Other B))))))))
    ("0\t1\tfile" (
      Ok (
        (key (One_file file))
        (num_stat (
          Num_lines_in_diff (
            (insertions 0)
            (deletions  1)))))))
    ("1985\t0\tfile1 => file2" (
      Ok (
        (key (
          Two_files
          (src file1)
          (dst file2)))
        (num_stat (
          Num_lines_in_diff (
            (insertions 1985)
            (deletions  0)))))))
    ("100\t5\ttmp/{dir1 => dir2}/file" (
      Ok (
        (key (
          Two_files
          (src tmp/dir1/file)
          (dst tmp/dir2/file)))
        (num_stat (
          Num_lines_in_diff (
            (insertions 100)
            (deletions  5)))))))
    ("-\t-\tfile" (Ok ((key (One_file file)) (num_stat Binary_file))))
    ("-\t10\tfile" (
      Error (
        (context (
          Vcs_git_backend.Num_status.parse_line_exn ((line "-\t10\tfile"))))
        (error (
          "Unexpected output from git diff." (
            (insertions Dash) (deletions (Num 10))))))))
    ("7\t-\tfile" (
      Error (
        (context (Vcs_git_backend.Num_status.parse_line_exn ((line "7\t-\tfile"))))
        (error (
          "Unexpected output from git diff." (
            (insertions (Num 7)) (deletions Dash)))))))
    ("-2\t-10\tfile" (
      Error (
        (context (
          Vcs_git_backend.Num_status.parse_line_exn ((line "-2\t-10\tfile"))))
        (error (
          "Unexpected output from git diff." (
            (insertions (Other -2))
            (deletions  (Other -10))))))))
    ("1985\t0\tfile1 => /tmp/file2" (
      Error (
        (context
          (Vcs_git_backend.Num_status.parse_line_exn
           ((line "1985\t0\tfile1 => /tmp/file2")))
          (Vcs_git_backend.Munged_path.parse_exn ((path "file1 => /tmp/file2"))))
        (error (Invalid_argument "\"/tmp/file2\": not a relative path")))))
    |}];
  ()
;;
