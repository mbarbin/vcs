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

let%expect_test "to_string" =
  let test t =
    let str = Vcs.Url.to_string t in
    print_endline str;
    let t' = Vcs.Url.of_string str |> Or_error.ok_exn in
    require_equal [%here] (module Vcs.Url) t t'
  in
  test
    { platform = GitHub
    ; protocol = Https
    ; user_handle = Vcs.User_handle.v "ahrefs"
    ; repo_name = Vcs.Repo_name.v "atd"
    };
  [%expect {| https://github.com/ahrefs/atd.git |}];
  test
    { platform = GitHub
    ; protocol = Ssh
    ; user_handle = Vcs.User_handle.v "mbarbin"
    ; repo_name = Vcs.Repo_name.v "ocaml-grpc"
    };
  [%expect {| git@github.com:mbarbin/ocaml-grpc.git |}];
  ()
;;

let%expect_test "of_string" =
  let test str = print_s [%sexp (Vcs.Url.of_string str : Vcs.Url.t Or_error.t)] in
  test "";
  [%expect {| (Error ("Invalid url" ((url "")))) |}];
  test "mbarbin/myrepo";
  [%expect {| (Error ("Invalid url" ((url mbarbin/myrepo)))) |}];
  test "https://github.com/myrepo";
  [%expect
    {| (Error ("Invalid url" ((url https://github.com/myrepo)) "missing user handle")) |}];
  test "https://github.com/user/myrepo";
  [%expect
    {|
    (Error (
      "Invalid url" ((url https://github.com/user/myrepo)) "missing .git suffix")) |}];
  test "https://github.com/user/myrepo.git";
  [%expect
    {|
    (Ok (
      (platform    GitHub)
      (protocol    Https)
      (user_handle user)
      (repo_name   myrepo))) |}];
  ()
;;
