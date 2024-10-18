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

let%expect_test "monitor-hashes" =
  List.iter Vcs.Platform.all ~f:(fun t ->
    let stdlib_hash = Stdlib.Hashtbl.hash t in
    let vcs_hash = Vcs.Platform.hash t in
    let vcs_base_hash = Vcs_base.Vcs.Platform.hash t in
    print_s
      [%sexp
        (t : Vcs.Platform.t), { stdlib_hash : int; vcs_hash : int; vcs_base_hash : int }]);
  [%expect
    {|
    (GitHub (
      (stdlib_hash   129913994)
      (vcs_hash      129913994)
      (vcs_base_hash 0)))
    |}];
  ()
;;
