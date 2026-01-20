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

module Vcs = Volgo_base.Vcs

let%expect_test "to_error" =
  let test err = print_s (Vcs.Err.to_error err |> Error.sexp_of_t) in
  test (Err.create [ Pp.text "Hello" ]);
  [%expect {| Hello |}];
  test
    (Err.add_context
       (Err.create [ Err.sexp (Dyn.to_sexp (Dyn.variant "Hello" [])) ])
       [ Err.sexp (Dyn.to_sexp (Dyn.variant "Step" [])) ]);
  [%expect {| ((context Step) (error Hello)) |}];
  test (Err.create [ Pp.text "Hello"; Err.sexp (Dyn.to_sexp (Dyn.variant "Step" [])) ]);
  [%expect {| (Hello Step) |}];
  ()
;;

let%expect_test "of_error" =
  let test err = print_s (Vcs.Err.of_error err |> Err.sexp_of_t) in
  test (Error.create_s (Dyn.to_sexp (Dyn.variant "Hello" [])));
  [%expect {| Hello |}];
  ()
;;
