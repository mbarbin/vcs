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

open! Import

type err = Vcs_rresult0.t [@@deriving sexp_of]
type 'a t = ('a, err) Result.t [@@deriving sexp_of]
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
