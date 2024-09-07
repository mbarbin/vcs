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

let%expect_test "of_string" =
  let test str =
    match Vcs.Remote_branch_name.of_string str with
    | Error (`Msg m) -> print_s [%sexp Error (m : string)]
    | Ok a -> print_endline (Vcs.Remote_branch_name.to_string a)
  in
  test "no space";
  [%expect {| (Error "\"no space\": invalid remote_branch_name") |}];
  test "slashes/are/allowed";
  [%expect {| slashes/are/allowed |}];
  test "origin/main";
  [%expect {| origin/main |}];
  test "origin/dashes-and_underscores";
  [%expect {| origin/dashes-and_underscores |}];
  test "local-branch";
  [%expect {| (Error "\"local-branch\": invalid remote_branch_name") |}];
  (* Some characters are currently not accepted. *)
  test "\\";
  [%expect {| (Error "\"\\\\\": invalid remote_branch_name") |}];
  (* And we do not accept the empty string. *)
  test "";
  [%expect {| (Error "\"\": invalid remote_branch_name") |}];
  ()
;;
