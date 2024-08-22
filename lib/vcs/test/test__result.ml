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

let%expect_test "pp_error" =
  Vcs.Result.pp_error Stdlib.Format.std_formatter (`Vcs (Vcs.Err.create_s [%sexp Hello]));
  [%expect {| Hello |}];
  ()
;;

let%expect_test "error_to_msg" =
  let test r =
    print_s [%sexp (Vcs.Result.error_to_msg r : (unit, [ `Msg of string ]) Result.t)]
  in
  test (Ok ());
  [%expect {| (Ok ()) |}];
  test (Error (`Vcs (Vcs.Err.create_s [%sexp Hello])));
  [%expect {| (Error (Msg Hello)) |}];
  ()
;;

let%expect_test "open_error" =
  (* Here we simulate a program where the type for errors changes as we go. *)
  let result =
    let%bind.Result () = Result.return () in
    Result.return ()
  in
  print_s [%sexp (result : (unit, unit) Result.t)];
  [%expect {| (Ok ()) |}];
  let result =
    let%bind.Result () = result in
    let%bind.Result () = (Result.return () : (unit, [ `My_int_error of int ]) Result.t) in
    Result.return ()
  in
  print_s [%sexp (result : (unit, [ `My_int_error of int ]) Result.t)];
  [%expect {| (Ok ()) |}];
  let result =
    let%bind.Result () =
      match result with
      | Ok _ as r -> r
      | Error (`My_int_error _) as r -> r [@coverage off]
    in
    let ok = (Ok () : unit Vcs.Result.result) in
    let%bind.Result () = Vcs.Result.open_error ok in
    let error = Error (`Vcs (Vcs.Err.create_s [%sexp Vcs_error])) in
    let%bind.Result () = Vcs.Result.open_error error in
    (Result.return () [@coverage off])
  in
  print_s [%sexp (result : (unit, [ `My_int_error of int | `Vcs of Vcs.Err.t ]) Result.t)];
  [%expect {| (Error (Vcs Vcs_error)) |}];
  ()
;;
