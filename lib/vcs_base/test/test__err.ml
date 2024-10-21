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

module Vcs = Vcs_base.Vcs

let%expect_test "to_error" =
  let test err = print_s [%sexp (Vcs.Err.to_error err : Error.t)] in
  test (Vcs.Err.create_s [%sexp Hello]);
  [%expect {| Hello |}];
  test (Vcs.Err.init [%sexp Hello] ~step:[%sexp Step]);
  [%expect {| ((steps (Step)) (error Hello)) |}];
  ()
;;

let%expect_test "of_error" =
  let test err = print_s [%sexp (Vcs.Err.of_error err : Vcs.Err.t)] in
  test (Error.create_s [%sexp Hello]);
  [%expect {| Hello |}];
  ()
;;
