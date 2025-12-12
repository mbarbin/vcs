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

open! Import

type err = Vcs_rresult0.t

let sexp_of_err = Vcs_rresult0.sexp_of_t

type 'a t = ('a, err) Result.t

let sexp_of_t : 'a. ('a -> Sexplib0.Sexp.t) -> 'a t -> Sexplib0.Sexp.t =
  fun _of_a__001_ -> fun x__002_ -> Result.sexp_of_t _of_a__001_ sexp_of_err x__002_
;;

type 'a result = 'a t

include Non_raising.Make (Vcs_rresult0)

let pp_error fmt (`Vcs err) = Format.pp_print_string fmt (Err.to_string_hum err)

let open_error = function
  | Ok _ as r -> r
  | Error (`Vcs _) as r -> r
;;

let error_to_msg (r : 'a result) =
  Result.map_error r ~f:(fun (`Vcs err) -> `Msg (Err.to_string_hum err))
;;
