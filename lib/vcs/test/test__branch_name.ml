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
    match Vcs.Branch_name.of_string str with
    | Error e -> print_s [%sexp Error (e : Error.t)]
    | Ok a -> print_endline (Vcs.Branch_name.to_string a)
  in
  test "no space";
  [%expect {| (Error ("Branch_name.of_string: invalid entry" "no space")) |}];
  test "slashes/are/allowed";
  [%expect {| slashes/are/allowed |}];
  test "dashes-and_underscores";
  [%expect {| dashes-and_underscores |}];
  test "other+chars@are+allowed";
  [%expect {| other+chars@are+allowed |}];
  (* Some characters are currently not accepted. *)
  test "\\";
  [%expect {| (Error ("Branch_name.of_string: invalid entry" \)) |}];
  (* And we do not accept the empty string. *)
  test "";
  [%expect {| (Error ("Branch_name.of_string: invalid entry" "")) |}];
  ()
;;
