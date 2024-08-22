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
    match Vcs.Tag_name.of_string str with
    | Error e -> print_s [%sexp Error (e : Error.t)]
    | Ok a -> print_endline (Vcs.Tag_name.to_string a)
  in
  test "no space";
  [%expect {| (Error ("Tag_name.of_string: invalid entry" "no space")) |}];
  test "slashes/are/not/allowed";
  [%expect {| (Error ("Tag_name.of_string: invalid entry" slashes/are/not/allowed)) |}];
  test "dashes-and_underscores";
  [%expect {| dashes-and_underscores |}];
  test "0.1.8";
  [%expect {| 0.1.8 |}];
  test "v0.1.8";
  [%expect {| v0.1.8 |}];
  test "1.0.0-beta+exp.sha.5114f85";
  [%expect {| 1.0.0-beta+exp.sha.5114f85 |}];
  (* Some characters are currently not accepted. *)
  test "\\";
  [%expect {| (Error ("Tag_name.of_string: invalid entry" \)) |}];
  (* And we do not accept the empty string. *)
  test "";
  [%expect {| (Error ("Tag_name.of_string: invalid entry" "")) |}];
  ()
;;

let%expect_test "no ~" =
  (* At one point we were tempted to allow '~' as a valid tag character, since
     it is used as part of preview version names such as [0.1.0~preview].
     However, this is rejected by git itself so we shouldn't allow it. *)
  require_does_raise [%here] (fun () -> Vcs.Tag_name.v "1.4.5~preview-0.1");
  [%expect {| ("Tag_name.of_string: invalid entry" 1.4.5~preview-0.1) |}]
;;
