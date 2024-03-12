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

let%expect_test "show" =
  let test output =
    print_s
      [%sexp
        (Git_cli.Show.interpret_output output
         : [ `Absent | `Present of Vcs.File_contents.t ] Or_error.t)]
  in
  test { exit_code = 0; stdout = "contents"; stderr = "" };
  [%expect {| (Ok (Present contents)) |}];
  test { exit_code = 128; stdout = "contents"; stderr = "" };
  [%expect {| (Ok Absent) |}];
  test { exit_code = 1; stdout = "contents"; stderr = "" };
  [%expect {| (Error "expected error code 0 or 128") |}];
  ()
;;
