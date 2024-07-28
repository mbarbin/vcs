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

(* In this test we run a function from the Vcs API, let it raise an exception
   and show out to catch it. This allows for a basic coverage of the raising
   case of the API too. *)

let%expect_test "hello error" =
  Eio_main.run
  @@ fun env ->
  let vcs = Vcs_git.create ~env in
  let invalid_path = Absolute_path.v "/invalid/path" in
  let redact_sexp sexp =
    (* Because the actual error may become too brittle overtime, we actually
       redact it. *)
    Vcs_test_helpers.redact_sexp sexp ~fields:[ "error/error" ]
  in
  let () =
    match Vcs.init vcs ~path:invalid_path with
    | _ -> assert false
    | exception Vcs.E err -> print_s (redact_sexp [%sexp (err : Vcs.Err.t)])
  in
  [%expect
    {|
    ((steps ((Vcs.init ((path /invalid/path)))))
     (error (
       (prog git)
       (args (init .))
       (exit_status Unknown)
       (cwd         /invalid/path)
       (stdout      "")
       (stderr      "")
       (error       <REDACTED>))))
    |}];
  (* Let's do the same with the non-raising interfaces. *)
  let () =
    match Vcs.Or_error.init vcs ~path:invalid_path with
    | Ok _ -> assert false
    | Error err -> print_s (redact_sexp [%sexp (err : Error.t)])
  in
  [%expect
    {|
    ((steps ((Vcs.init ((path /invalid/path)))))
     (error (
       (prog git)
       (args (init .))
       (exit_status Unknown)
       (cwd         /invalid/path)
       (stdout      "")
       (stderr      "")
       (error       <REDACTED>))))
    |}];
  let () =
    match Vcs.Result.init vcs ~path:invalid_path with
    | Ok _ -> assert false
    | Error (`Vcs err) -> print_s (redact_sexp [%sexp (err : Vcs.Err.t)])
  in
  [%expect
    {|
    ((steps ((Vcs.init ((path /invalid/path)))))
     (error (
       (prog git)
       (args (init .))
       (exit_status Unknown)
       (cwd         /invalid/path)
       (stdout      "")
       (stderr      "")
       (error       <REDACTED>))))
    |}];
  ()
;;
