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

let%expect_test "to_string o of_string" =
  let ts =
    let open List.Let_syntax in
    let%bind platform = Vcs.Platform.all in
    let%bind vcs_kind =
      match platform with
      | GitHub | GitLab | Codeberg -> [ Vcs.Platform_repo.Vcs_kind.Git ]
      | Bitbucket | Sourcehut -> Vcs.Platform_repo.Vcs_kind.all
    in
    let user_handle = Vcs.User_handle.v "user" in
    let repo_name = Vcs.Repo_name.v "repo" in
    let%bind protocol = Vcs.Platform_repo.Protocol.all in
    let%bind ssh_syntax =
      match protocol with
      | Https -> [ Vcs.Platform_repo.Ssh_syntax.Url_style ]
      | Ssh -> Vcs.Platform_repo.Ssh_syntax.all
    in
    return
      ( { Vcs.Platform_repo.Url.platform; vcs_kind; user_handle; repo_name; protocol }
      , ssh_syntax )
  in
  List.iter ts ~f:(fun (t, ssh_syntax) ->
    let str = Vcs.Platform_repo.Url.to_string t ~ssh_syntax in
    print_endline str;
    let t' = Vcs.Platform_repo.Url.v str in
    let t' =
      match t.platform, t.protocol, t.vcs_kind with
      | Bitbucket, Https, Hg ->
        (* This is a known limitation - we're not able to distinguish Git and Hg
           here, and default to assume Git. *)
        require_equal [%here] (module Vcs.Platform_repo.Vcs_kind) t'.vcs_kind Git;
        { t' with vcs_kind = Hg }
      | _ -> t'
    in
    require_equal [%here] (module Vcs.Platform_repo.Url) t t');
  [%expect
    {|
    git@bitbucket.org:user/repo.git
    ssh://git@bitbucket.org/user/repo.git
    https://bitbucket.org/user/repo.git
    hg@bitbucket.org:user/repo
    ssh://hg@bitbucket.org/user/repo
    https://bitbucket.org/user/repo
    git@codeberg.org:user/repo.git
    ssh://git@codeberg.org/user/repo.git
    https://codeberg.org/user/repo.git
    git@github.com:user/repo.git
    ssh://git@github.com/user/repo.git
    https://github.com/user/repo.git
    git@gitlab.com:user/repo.git
    ssh://git@gitlab.com/user/repo.git
    https://gitlab.com/user/repo.git
    git@git.sr.ht:~user/repo.git
    ssh://git@git.sr.ht/~user/repo.git
    https://git.sr.ht/~user/repo.git
    hg@hg.sr.ht:~user/repo
    ssh://hg@hg.sr.ht/~user/repo
    https://hg.sr.ht/~user/repo
    |}];
  ()
;;

(* Here we show example of strings that we are able to parse for convenience,
   but that we are not printing the exact same way. We do however verify that
   their parsed result yield the same values (and the string repr is stable
   after 1 iteration). *)

let%expect_test "parse" =
  let test candidate =
    let t = Vcs.Platform_repo.Url.v candidate in
    let str = Vcs.Platform_repo.Url.to_url_string t in
    let t' = Vcs.Platform_repo.Url.v str in
    require_equal [%here] (module Vcs.Platform_repo.Url) t t';
    let str2 = Vcs.Platform_repo.Url.to_url_string t' in
    require_equal [%here] (module String) str str2;
    print_endline str;
    ()
  in
  test "https://github.com/user/repo";
  [%expect {| https://github.com/user/repo.git |}];
  ()
;;

let%expect_test "to_platform_string" =
  let test t =
    let url = Vcs.Platform_repo.to_url t ~protocol:Ssh in
    let str = Vcs.Platform_repo.Url.to_platform_string url in
    print_endline str;
    let url' = Vcs.Platform_repo.Url.v str in
    require_equal [%here] (module Vcs.Platform_repo.Url) url url';
    let t' = Vcs.Platform_repo.of_url url' in
    require_equal [%here] (module Vcs.Platform_repo) t t';
    ()
  in
  test
    { platform = GitHub
    ; vcs_kind = Git
    ; user_handle = Vcs.User_handle.v "user"
    ; repo_name = Vcs.Repo_name.v "repo"
    };
  [%expect {| git@github.com:user/repo.git |}];
  test
    { platform = Codeberg
    ; vcs_kind = Git
    ; user_handle = Vcs.User_handle.v "user"
    ; repo_name = Vcs.Repo_name.v "repo"
    };
  [%expect {| ssh://git@codeberg.org/user/repo.git |}];
  ()
;;

let%expect_test "ssh_syntax" =
  List.iter Vcs.Platform.all ~f:(fun platform ->
    let used_by_default_on_platform =
      Vcs.Platform_repo.Ssh_syntax.used_by_default_on_platform ~platform
    in
    print_s
      [%sexp
        { platform : Vcs.Platform.t
        ; used_by_default_on_platform : Vcs.Platform_repo.Ssh_syntax.t
        }]);
  [%expect
    {|
    ((platform                    Bitbucket)
     (used_by_default_on_platform Url_style))
    ((platform                    Codeberg)
     (used_by_default_on_platform Url_style))
    ((platform                    GitHub)
     (used_by_default_on_platform Scp_like))
    ((platform                    GitLab)
     (used_by_default_on_platform Scp_like))
    ((platform                    Sourcehut)
     (used_by_default_on_platform Scp_like))
    |}];
  ()
;;

let%expect_test "of_string msgs" =
  (* The parsing function attempts to provide useful error messages. *)
  let test str =
    print_s
      [%sexp
        (Vcs.Platform_repo.Url.of_string str
         : (Vcs.Platform_repo.Url.t, [ `Msg of string ]) Result.t)]
  in
  test "";
  [%expect {| (Error (Msg "\"\": invalid url")) |}];
  test "mbarbin/my_repo";
  [%expect {| (Error (Msg "\"mbarbin/my_repo\": invalid url")) |}];
  (* https *)
  test "https://github.com/myrepo";
  [%expect
    {| (Error (Msg "\"https://github.com/myrepo\": invalid url. missing user handle")) |}];
  test "https://github.com/user/myrepo";
  [%expect
    {|
    (Ok (
      (platform    GitHub)
      (vcs_kind    Git)
      (user_handle user)
      (repo_name   myrepo)
      (protocol    Https)))
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
      (vcs_kind    Git)
      (user_handle user)
      (repo_name   repo)
      (protocol    Https)))
    |}];
  (* scp-like ssh *)
  test "git@github.com:myrepo";
  [%expect
    {| (Error (Msg "\"git@github.com:myrepo\": invalid url. missing user handle")) |}];
  test "git@github.com:user/myrepo";
  [%expect
    {|
    (Ok (
      (platform    GitHub)
      (vcs_kind    Git)
      (user_handle user)
      (repo_name   myrepo)
      (protocol    Ssh)))
    |}];
  test "git@github.com:invalid user/my_repo.git";
  [%expect
    {|
    (Error (
      Msg
      "\"git@github.com:invalid user/my_repo.git\": invalid url. \"invalid user\": invalid user_handle"))
    |}];
  test "git@github.com:user/invalid repo.git";
  [%expect
    {|
    (Error (
      Msg
      "\"git@github.com:user/invalid repo.git\": invalid url. \"invalid repo\": invalid repo_name"))
    |}];
  test "git@github.com/user/repo.git";
  [%expect {| (Error (Msg "\"git@github.com/user/repo.git\": invalid url")) |}];
  test "git@github.com:user/repo.git";
  [%expect
    {|
    (Ok (
      (platform    GitHub)
      (vcs_kind    Git)
      (user_handle user)
      (repo_name   repo)
      (protocol    Ssh)))
    |}];
  (* url-like ssh *)
  test "ssh://git@codeberg.org/user/repo.git";
  [%expect
    {|
    (Ok (
      (platform    Codeberg)
      (vcs_kind    Git)
      (user_handle user)
      (repo_name   repo)
      (protocol    Ssh)))
    |}];
  test "ssh://git@github.com/user/repo.git";
  [%expect
    {|
    (Ok (
      (platform    GitHub)
      (vcs_kind    Git)
      (user_handle user)
      (repo_name   repo)
      (protocol    Ssh)))
    |}];
  test "ssh://git@codeberg.org/repo.git";
  [%expect
    {|
    (Error (
      Msg "\"ssh://git@codeberg.org/repo.git\": invalid url. missing user handle"))
    |}];
  (* sourcehut *)
  test "git@git.sr.ht:user/repo.git";
  [%expect
    {|
    (Error (
      Msg
      "\"git@git.sr.ht:user/repo.git\": invalid url. User namespace on sourcehut are expected to start with a '~' char."))
    |}];
  test "ssh://git@git.sr.ht/user/repo.git";
  [%expect
    {|
    (Error (
      Msg
      "\"ssh://git@git.sr.ht/user/repo.git\": invalid url. User namespace on sourcehut are expected to start with a '~' char."))
    |}];
  test "https://git.sr.ht/user/repo.git";
  [%expect
    {|
    (Error (
      Msg
      "\"https://git.sr.ht/user/repo.git\": invalid url. User namespace on sourcehut are expected to start with a '~' char."))
    |}];
  ()
;;

let%expect_test "v" =
  let test str =
    print_s [%sexp (Vcs.Platform_repo.Url.v str : Vcs.Platform_repo.Url.t)]
  in
  require_does_raise [%here] (fun () -> test "user/my_repo");
  [%expect {| (Invalid_argument "\"user/my_repo\": invalid url") |}];
  test "https://github.com/user/repo.git";
  [%expect
    {|
    ((platform    GitHub)
     (vcs_kind    Git)
     (user_handle user)
     (repo_name   repo)
     (protocol    Https))
    |}];
  ()
;;
