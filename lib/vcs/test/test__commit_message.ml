(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Interaction                        *)
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
    match Vcs.Commit_message.of_string str with
    | Error e -> print_s [%sexp Error (e : Error.t)]
    | Ok a -> print_endline (Vcs.Commit_message.to_string a)
  in
  (* We do not accept the empty string. *)
  test "";
  [%expect {| (Error ("Commit_message.of_string: invalid entry" "")) |}];
  (* Currently all characters are currently accepted. *)
  test "\\ including _ spaces and \n newlines";
  [%expect {|
    \ including _ spaces and
     newlines |}];
  (* However we reject entries that are too long. The limit may change later, TBD. *)
  test (String.make 10000 'a');
  [%expect
    {|
    (Error (
      "Commit_message.of_string: invalid entry"
      "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa... (10000 characters total)")) |}];
  ()
;;
