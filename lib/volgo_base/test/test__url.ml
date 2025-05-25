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

let%expect_test "protocol-hash" =
  Hash_test.run
    (module Vcs.Url.Protocol)
    (module Volgo_base.Vcs.Url.Protocol)
    Vcs.Url.Protocol.all;
  [%expect
    {|
    (((value Ssh))
     ((stdlib_hash   129913994)
      (vcs_hash      129913994)
      (vcs_base_hash 1058613066)))
    (((value Ssh)
      (seed  0))
     ((stdlib_hash   129913994)
      (vcs_hash      129913994)
      (vcs_base_hash 1058613066)))
    (((value Ssh)
      (seed  42))
     ((stdlib_hash   269061838)
      (vcs_hash      269061838)
      (vcs_base_hash 992140660)))
    (((value Https))
     ((stdlib_hash   883721435)
      (vcs_hash      883721435)
      (vcs_base_hash 129913994)))
    (((value Https)
      (seed  0))
     ((stdlib_hash   883721435)
      (vcs_hash      883721435)
      (vcs_base_hash 129913994)))
    (((value Https)
      (seed  42))
     ((stdlib_hash   166027884)
      (vcs_hash      166027884)
      (vcs_base_hash 269061838)))
    |}];
  ()
;;

let values =
  [ { Vcs.Url.platform = GitHub
    ; protocol = Ssh
    ; user_handle = Vcs.User_handle.v "jdoe"
    ; repo_name = Vcs.Repo_name.v "vcs"
    }
  ; { Vcs.Url.platform = GitHub
    ; protocol = Https
    ; user_handle = Vcs.User_handle.v "jdoe"
    ; repo_name = Vcs.Repo_name.v "vcs"
    }
  ]
;;

let%expect_test "hash" =
  Hash_test.run (module Vcs.Url) (module Volgo_base.Vcs.Url) values;
  [%expect
    {|
    (((
       value (
         (platform    GitHub)
         (protocol    Ssh)
         (user_handle jdoe)
         (repo_name   vcs))))
     ((stdlib_hash   985339529)
      (vcs_hash      985339529)
      (vcs_base_hash 379123824)))
    (((value (
        (platform    GitHub)
        (protocol    Ssh)
        (user_handle jdoe)
        (repo_name   vcs)))
      (seed 0))
     ((stdlib_hash   985339529)
      (vcs_hash      985339529)
      (vcs_base_hash 379123824)))
    (((value (
        (platform    GitHub)
        (protocol    Ssh)
        (user_handle jdoe)
        (repo_name   vcs)))
      (seed 42))
     ((stdlib_hash   403159267)
      (vcs_hash      403159267)
      (vcs_base_hash 455185329)))
    (((
       value (
         (platform    GitHub)
         (protocol    Https)
         (user_handle jdoe)
         (repo_name   vcs))))
     ((stdlib_hash   738318452)
      (vcs_hash      738318452)
      (vcs_base_hash 175273566)))
    (((value (
        (platform    GitHub)
        (protocol    Https)
        (user_handle jdoe)
        (repo_name   vcs)))
      (seed 0))
     ((stdlib_hash   738318452)
      (vcs_hash      738318452)
      (vcs_base_hash 175273566)))
    (((value (
        (platform    GitHub)
        (protocol    Https)
        (user_handle jdoe)
        (repo_name   vcs)))
      (seed 42))
     ((stdlib_hash   578334967)
      (vcs_hash      578334967)
      (vcs_base_hash 1022761584)))
    |}];
  ()
;;
