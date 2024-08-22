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

(* Most of [Vcs_arg] is tested via the vcs cram tests. This file contains
   additional tests that help covering corner cases. *)

let%expect_test "not-in-repo" =
  Eio_main.run
  @@ fun env ->
  (match
     Vcs_arg.Context.create ~cwd:Absolute_path.root ~env ~config:Vcs_arg.Config.default ()
   with
   | _ -> assert false
   | exception Vcs.E err -> print_s [%sexp (err : Vcs.Err.t)]);
  [%expect {| ("Not in a supported version control repo" ((cwd /))) |}];
  ()
;;
