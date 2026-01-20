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

let%expect_test "of_string" =
  let test s =
    match Vcs.Path_in_repo.of_string s with
    | Ok a -> print_endline (Vcs.Path_in_repo.to_string a)
    | Error (`Msg m) -> print_dyn (Dyn.Variant ("Error", [ Dyn.string m ]))
  in
  test "";
  [%expect {| Error "\"\": invalid path" |}];
  test ".";
  [%expect {| ./ |}];
  test "/";
  [%expect {| Error "\"/\" is not a relative path" |}];
  test "/a/foo";
  [%expect {| Error "\"/a/foo\" is not a relative path" |}];
  test "a/foo/bar";
  [%expect {| a/foo/bar |}];
  (* We do keep the trailing slashes if present syntactically. Although we do
     not expect such paths to be computed by the [Vcs] library from files
     present in the repo. *)
  test "a/foo/bar/";
  [%expect {| a/foo/bar/ |}];
  test "file";
  [%expect {| file |}];
  test "a/foo/bar/../sna";
  [%expect {| a/foo/sna |}];
  ()
;;
