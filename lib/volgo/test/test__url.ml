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

let%expect_test "to_string" =
  let test t =
    let str = Vcs.Url.to_string t in
    print_endline str;
    let t' = Vcs.Url.v str in
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
  let test str =
    print_s [%sexp (Vcs.Url.of_string str : (Vcs.Url.t, [ `Msg of string ]) Result.t)]
  in
  test "";
  [%expect {| (Error (Msg "\"\": invalid url")) |}];
  test "mbarbin/my_repo";
  [%expect {| (Error (Msg "\"mbarbin/my_repo\": invalid url")) |}];
  test "https://github.com/myrepo";
  [%expect
    {| (Error (Msg "\"https://github.com/myrepo\": invalid url. missing user handle")) |}];
  test "https://github.com/user/myrepo";
  [%expect
    {|
    (Error (
      Msg "\"https://github.com/user/myrepo\": invalid url. missing .git suffix"))
    |}];
  test "https://github.com/invalid user/my_repo.git";
  [%expect
    {|
    (Error (
      Msg
      "\"https://github.com/invalid user/my_repo.git\": invalid url. \"invalid user\": invalid user_handle"))
    |}];
  test "https://github.com/user/invalid repo.git";
  [%expect
    {|
    (Error (
      Msg
      "\"https://github.com/user/invalid repo.git\": invalid url. \"invalid repo\": invalid repo_name"))
    |}];
  test "https://github.com/user/repo.git";
  [%expect
    {|
    (Ok (
      (platform    GitHub)
      (protocol    Https)
      (user_handle user)
      (repo_name   repo)))
    |}];
  ()
;;

let%expect_test "v" =
  let test str = print_s [%sexp (Vcs.Url.v str : Vcs.Url.t)] in
  require_does_raise [%here] (fun () -> test "user/my_repo");
  [%expect {| (Invalid_argument "\"user/my_repo\": invalid url") |}];
  test "https://github.com/user/repo.git";
  [%expect
    {|
    ((platform    GitHub)
     (protocol    Https)
     (user_handle user)
     (repo_name   repo))
    |}];
  ()
;;
