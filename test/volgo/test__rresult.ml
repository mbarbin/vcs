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

let%expect_test "sexp_of_t" =
  let test r = print_s (r |> Vcs.Rresult.sexp_of_t Int.sexp_of_t) in
  test (Result.return 0);
  [%expect {| (Ok 0) |}];
  test (Error (`Vcs (Err.create [ Pp.text "Hello Rresult error" ])));
  [%expect {| (Error (Vcs "Hello Rresult error")) |}];
  ()
;;

let%expect_test "pp_error" =
  Vcs.Rresult.pp_error Stdlib.Format.std_formatter (`Vcs (Err.create [ Pp.text "Hello" ]));
  [%expect {| Hello |}];
  ()
;;

module Msg = struct
  [@@@coverage off]

  type t = [ `Msg of string ]

  let to_dyn (`Msg s : t) = Dyn.Variant ("Msg", [ Dyn.string s ])
end

let%expect_test "error_to_msg" =
  let test r = print_dyn (Vcs.Rresult.error_to_msg r |> Dyn.result Dyn.unit Msg.to_dyn) in
  test (Ok ());
  [%expect {| Ok () |}];
  test (Error (`Vcs (Err.create [ Pp.text "Hello" ])));
  [%expect {| Error (Msg "Hello") |}];
  ()
;;

module My_int_error = struct
  [@@@coverage off]

  type t = [ `My_int_error of int ]

  let to_dyn (`My_int_error s : t) = Dyn.Variant ("My_int_error", [ Dyn.int s ])
end

module My_open_error = struct
  [@@@coverage off]

  type t =
    [ `My_int_error of int
    | `Vcs of Err.t
    ]

  let to_dyn t =
    match (t : t) with
    | `My_int_error i -> Dyn.Variant ("My_int_error", [ Dyn.int i ])
    | `Vcs err -> Dyn.Variant ("Vcs", [ Dyn.string (Err.to_string_hum err) ])
  ;;
end

let%expect_test "open_error" =
  (* Here we simulate a program where the type for errors changes as we go. *)
  let open Result.Syntax in
  let result =
    let* () = Result.return () in
    Result.return ()
  in
  print_dyn (result |> Dyn.result Dyn.unit Dyn.unit);
  [%expect {| Ok () |}];
  let result =
    let* () = result in
    let* () = (Result.return () : (unit, [ `My_int_error of int ]) Result.t) in
    Result.return ()
  in
  print_dyn (result |> Dyn.result Dyn.unit My_int_error.to_dyn);
  [%expect {| Ok () |}];
  let result =
    let* () =
      match result with
      | Ok _ as r -> r
      | Error (`My_int_error _) as r -> r [@coverage off]
    in
    let ok = (Ok () : unit Vcs.Rresult.t) in
    let* () = Vcs.Rresult.open_error ok in
    let error = Error (`Vcs (Err.create [ Pp.text "Vcs_error" ])) in
    let* () = Vcs.Rresult.open_error error in
    (Result.return () [@coverage off])
  in
  print_dyn (result |> Dyn.result Dyn.unit My_open_error.to_dyn);
  [%expect {| Error (Vcs "Vcs_error") |}];
  ()
;;
