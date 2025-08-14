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

(* In this test we run a function from the Vcs API, let it raise an exception
   and show how to catch it. This allows for a basic coverage of the raising
   case of the API too. *)

let%expect_test "hello error" =
  Eio_main.run
  @@ fun env ->
  let vcs = Volgo_git_eio.create ~env in
  let invalid_path = Absolute_path.v "/invalid/path" in
  let redact_sexp sexp =
    (* Because the actual error may become too brittle overtime, we actually
       redact it. *)
    Vcs_test_helpers.redact_sexp sexp ~fields:[ "error" ]
  in
  let () =
    match Vcs.init vcs ~path:invalid_path with
    | _ -> assert false
    | exception Err.E err -> print_s (redact_sexp [%sexp (err : Err.t)])
  in
  [%expect
    {|
    ((context
       (Vcs.init (path /invalid/path))
       ((prog git)
        (args (init .))
        (exit_status Unknown)
        (cwd         /invalid/path)
        (stdout      "")
        (stderr      "")))
     (error <REDACTED>))
    |}];
  (* Let's do the same with the non-raising interfaces. *)
  let () =
    match Vcs.Or_error.init vcs ~path:invalid_path with
    | Ok _ -> assert false
    | Error err -> print_s (redact_sexp [%sexp (err : Error.t)])
  in
  [%expect
    {|
    ((context
       (Vcs.init (path /invalid/path))
       ((prog git)
        (args (init .))
        (exit_status Unknown)
        (cwd         /invalid/path)
        (stdout      "")
        (stderr      "")))
     (error <REDACTED>))
    |}];
  let () =
    match Vcs.Result.init vcs ~path:invalid_path with
    | Ok _ -> assert false
    | Error err -> print_s (redact_sexp [%sexp (err : Err.t)])
  in
  [%expect
    {|
    ((context
       (Vcs.init (path /invalid/path))
       ((prog git)
        (args (init .))
        (exit_status Unknown)
        (cwd         /invalid/path)
        (stdout      "")
        (stderr      "")))
     (error <REDACTED>))
    |}];
  let () =
    match Vcs.Rresult.init vcs ~path:invalid_path with
    | Ok _ -> assert false
    | Error err -> print_s (redact_sexp [%sexp (err : Vcs.Rresult.err)])
  in
  [%expect
    {|
    (Vcs (
      (context
        (Vcs.init (path /invalid/path))
        ((prog git)
         (args (init .))
         (exit_status Unknown)
         (cwd         /invalid/path)
         (stdout      "")
         (stderr      "")))
      (error <REDACTED>)))
    |}];
  ()
;;
