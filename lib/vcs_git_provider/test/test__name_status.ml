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

(* [super-master-mind.name-status] has been created by capturing the output of:

   {v
      $ git diff --name-status 1892d4980ee74945eb98f67be26b745f96c0f482..bcaf94757fe3cb247fa544445f0f41f3616943d7
   v}

   In this test we verify that we can parse this output.contents
*)

let%expect_test "parse_exn" =
  Eio_main.run
  @@ fun env ->
  let path = Eio.Path.(Eio.Stdenv.fs env / "super-master-mind.name-status") in
  let contents = Eio.Path.load path in
  let lines = String.split_lines contents in
  let name_status = Vcs_git_provider.Name_status.parse_lines_exn ~lines in
  print_s [%sexp (name_status : Vcs.Name_status.t)];
  [%expect
    {|
    ((Modified .github/workflows/ci.yml)
     (Removed  .github/workflows/deploy-odoc.yml)
     (Modified .vscode/settings.json)
     (Removed  CHANGELOG.md)
     (Added    CHANGES.md)
     (Removed  CODE_OF_CONDUCT.md)
     (Modified Makefile)
     (Modified README.md)
     (Modified bin/dune)
     (Modified bin/main.ml)
     (Modified dune-project)
     (Modified lib/super_master_mind/src/code.ml)
     (Modified lib/super_master_mind/src/code.mli)
     (Modified lib/super_master_mind/src/codes.ml)
     (Modified lib/super_master_mind/src/codes.mli)
     (Modified lib/super_master_mind/src/color.ml)
     (Modified lib/super_master_mind/src/color.mli)
     (Modified lib/super_master_mind/src/color_permutation.ml)
     (Modified lib/super_master_mind/src/color_permutation.mli)
     (Modified lib/super_master_mind/src/cue.ml)
     (Modified lib/super_master_mind/src/cue.mli)
     (Modified lib/super_master_mind/src/dune)
     (Modified lib/super_master_mind/src/example.ml)
     (Modified lib/super_master_mind/src/example.mli)
     (Modified lib/super_master_mind/src/game_dimensions.ml)
     (Modified lib/super_master_mind/src/game_dimensions.mli)
     (Modified lib/super_master_mind/src/guess.ml)
     (Modified lib/super_master_mind/src/guess.mli)
     (Added    lib/super_master_mind/src/import/dune)
     (Renamed
       (src lib/super_master_mind/src/import.ml)
       (dst lib/super_master_mind/src/import/super_master_mind_import.ml)
       (similarity 86))
     (Renamed
       (src lib/super_master_mind/src/import.mli)
       (dst lib/super_master_mind/src/import/super_master_mind_import.mli)
       (similarity 95))
     (Modified lib/super_master_mind/src/kheap.ml)
     (Modified lib/super_master_mind/src/kheap.mli)
     (Modified lib/super_master_mind/src/maker.ml)
     (Modified lib/super_master_mind/src/maker.mli)
     (Modified lib/super_master_mind/src/opening_book.ml)
     (Modified lib/super_master_mind/src/opening_book.mli)
     (Modified lib/super_master_mind/src/solver.ml)
     (Modified lib/super_master_mind/src/solver.mli)
     (Modified lib/super_master_mind/src/super_master_mind.ml)
     (Modified lib/super_master_mind/src/super_master_mind.mli)
     (Modified lib/super_master_mind/src/task_pool.ml)
     (Modified lib/super_master_mind/src/task_pool.mli)
     (Modified lib/super_master_mind/test/dune)
     (Modified lib/super_master_mind/test/test__code.ml)
     (Modified lib/super_master_mind/test/test__codes.ml)
     (Modified lib/super_master_mind/test/test__color.ml)
     (Modified lib/super_master_mind/test/test__color_permutation.ml)
     (Modified lib/super_master_mind/test/test__cue.ml)
     (Modified lib/super_master_mind/test/test__example.ml)
     (Modified lib/super_master_mind/test/test__game_dimensions.ml)
     (Modified lib/super_master_mind/test/test__guess.ml)
     (Modified lib/super_master_mind/test/test__kheap.ml)
     (Modified lib/super_master_mind/test/test__mins.ml)
     (Modified lib/super_master_mind/test/test__opening_book.ml)
     (Modified super-master-mind.opam)
     (Modified test/maker.t)) |}];
  print_s [%sexp (Vcs.Name_status.files name_status : Vcs.Path_in_repo.t list)];
  [%expect
    {|
    (.github/workflows/ci.yml
     .github/workflows/deploy-odoc.yml
     .vscode/settings.json
     CHANGELOG.md
     CHANGES.md
     CODE_OF_CONDUCT.md
     Makefile
     README.md
     bin/dune
     bin/main.ml
     dune-project
     lib/super_master_mind/src/code.ml
     lib/super_master_mind/src/code.mli
     lib/super_master_mind/src/codes.ml
     lib/super_master_mind/src/codes.mli
     lib/super_master_mind/src/color.ml
     lib/super_master_mind/src/color.mli
     lib/super_master_mind/src/color_permutation.ml
     lib/super_master_mind/src/color_permutation.mli
     lib/super_master_mind/src/cue.ml
     lib/super_master_mind/src/cue.mli
     lib/super_master_mind/src/dune
     lib/super_master_mind/src/example.ml
     lib/super_master_mind/src/example.mli
     lib/super_master_mind/src/game_dimensions.ml
     lib/super_master_mind/src/game_dimensions.mli
     lib/super_master_mind/src/guess.ml
     lib/super_master_mind/src/guess.mli
     lib/super_master_mind/src/import.ml
     lib/super_master_mind/src/import.mli
     lib/super_master_mind/src/import/dune
     lib/super_master_mind/src/import/super_master_mind_import.ml
     lib/super_master_mind/src/import/super_master_mind_import.mli
     lib/super_master_mind/src/kheap.ml
     lib/super_master_mind/src/kheap.mli
     lib/super_master_mind/src/maker.ml
     lib/super_master_mind/src/maker.mli
     lib/super_master_mind/src/opening_book.ml
     lib/super_master_mind/src/opening_book.mli
     lib/super_master_mind/src/solver.ml
     lib/super_master_mind/src/solver.mli
     lib/super_master_mind/src/super_master_mind.ml
     lib/super_master_mind/src/super_master_mind.mli
     lib/super_master_mind/src/task_pool.ml
     lib/super_master_mind/src/task_pool.mli
     lib/super_master_mind/test/dune
     lib/super_master_mind/test/test__code.ml
     lib/super_master_mind/test/test__codes.ml
     lib/super_master_mind/test/test__color.ml
     lib/super_master_mind/test/test__color_permutation.ml
     lib/super_master_mind/test/test__cue.ml
     lib/super_master_mind/test/test__example.ml
     lib/super_master_mind/test/test__game_dimensions.ml
     lib/super_master_mind/test/test__guess.ml
     lib/super_master_mind/test/test__kheap.ml
     lib/super_master_mind/test/test__mins.ml
     lib/super_master_mind/test/test__opening_book.ml
     super-master-mind.opam
     test/maker.t) |}];
  ()
;;

let%expect_test "Diff_status" =
  let entries = "ADMUQI?!XRCZ" in
  String.iter entries ~f:(fun char ->
    let diff_status =
      Vcs_git_provider.Name_status.Diff_status.parse_exn
        (Printf.sprintf "%c something" char)
    in
    print_s
      [%sexp (char : Char.t), (diff_status : Vcs_git_provider.Name_status.Diff_status.t)]);
  [%expect
    {|
    (A A)
    (D D)
    (M M)
    (U U)
    (Q Q)
    (I I)
    (? Question_mark)
    (! Bang)
    (X X)
    (R R)
    (C C)
    (Z Not_supported) |}];
  require_does_raise [%here] (fun () ->
    Vcs_git_provider.Name_status.Diff_status.parse_exn "");
  [%expect {| (Vcs.E "Unexpected empty diff status") |}];
  ()
;;

let%expect_test "parse_lines_exn" =
  let lines =
    [ ""
    ; "file"
    ; "A\tfile1"
    ; "D\tfile2"
    ; "M\tfile3"
    ; "U\tfile4"
    ; "Q\tfile5"
    ; "I\tfile6"
    ; "?\tfile7"
    ; "!\tfile8"
    ; "X\tfile9"
    ; "R\tfile10"
    ; "R35\tfile10"
    ; "R35\tfile1\tfile2"
    ; "C\tfile11"
    ; "C75\tfile1\tfile2"
    ; "Z\tfile12"
    ]
  in
  List.iter lines ~f:(fun line ->
    let result =
      Or_error.try_with (fun () -> Vcs_git_provider.Name_status.parse_line_exn ~line)
    in
    print_s [%sexp (line : string), (result : Vcs.Name_status.Change.t Or_error.t)]);
  [%expect
    {|
    ("" (
      Error (
        Vcs.E (
          (steps ((Vcs_git_provider.Name_status.parse_line_exn ((line "")))))
          (error "Unexpected output from git status")))))
    (file (
      Error (
        Vcs.E (
          (steps ((Vcs_git_provider.Name_status.parse_line_exn ((line file)))))
          (error "Unexpected output from git status")))))
    ("A\tfile1" (Ok (Added file1)))
    ("D\tfile2" (Ok (Removed file2)))
    ("M\tfile3" (Ok (Modified file3)))
    ("U\tfile4" (
      Error (
        Vcs.E (
          (steps ((
            Vcs_git_provider.Name_status.parse_line_exn ((line "U\tfile4")))))
          (error ("Unexpected status" U U))))))
    ("Q\tfile5" (
      Error (
        Vcs.E (
          (steps ((
            Vcs_git_provider.Name_status.parse_line_exn ((line "Q\tfile5")))))
          (error ("Unexpected status" Q Q))))))
    ("I\tfile6" (
      Error (
        Vcs.E (
          (steps ((
            Vcs_git_provider.Name_status.parse_line_exn ((line "I\tfile6")))))
          (error ("Unexpected status" I I))))))
    ("?\tfile7" (
      Error (
        Vcs.E (
          (steps ((
            Vcs_git_provider.Name_status.parse_line_exn ((line "?\tfile7")))))
          (error ("Unexpected status" ? Question_mark))))))
    ("!\tfile8" (
      Error (
        Vcs.E (
          (steps ((
            Vcs_git_provider.Name_status.parse_line_exn ((line "!\tfile8")))))
          (error ("Unexpected status" ! Bang))))))
    ("X\tfile9" (
      Error (
        Vcs.E (
          (steps ((
            Vcs_git_provider.Name_status.parse_line_exn ((line "X\tfile9")))))
          (error ("Unexpected status" X X))))))
    ("R\tfile10" (
      Error (
        Vcs.E (
          (steps ((
            Vcs_git_provider.Name_status.parse_line_exn ((line "R\tfile10")))))
          (error (Failure "Int.of_string: \"\""))))))
    ("R35\tfile10" (
      Error (
        Vcs.E (
          (steps ((
            Vcs_git_provider.Name_status.parse_line_exn ((line "R35\tfile10")))))
          (error "Unexpected output from git status")))))
    ("R35\tfile1\tfile2" (
      Ok (
        Renamed
        (src        file1)
        (dst        file2)
        (similarity 35))))
    ("C\tfile11" (
      Error (
        Vcs.E (
          (steps ((
            Vcs_git_provider.Name_status.parse_line_exn ((line "C\tfile11")))))
          (error (Failure "Int.of_string: \"\""))))))
    ("C75\tfile1\tfile2" (
      Ok (
        Copied
        (src        file1)
        (dst        file2)
        (similarity 75))))
    ("Z\tfile12" (
      Error (
        Vcs.E (
          (steps ((
            Vcs_git_provider.Name_status.parse_line_exn ((line "Z\tfile12")))))
          (error ("Unexpected status" Z Not_supported))))))
    |}];
  ()
;;
