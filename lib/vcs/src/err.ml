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

type t =
  { steps : Info.t list
  ; error : Error.t
  }
[@@deriving sexp_of]

let sexp_of_t ({ steps; error } as t) =
  if List.is_empty steps then Error.sexp_of_t error else sexp_of_t t
;;

let to_string_hum t = t |> sexp_of_t |> Sexp.to_string_hum
let create_s sexp = { steps = []; error = Error.create_s sexp }

let to_error t =
  match t.steps with
  | [] -> t.error
  | _ :: _ -> Error.create_s (sexp_of_t t)
;;

let of_error error = { steps = []; error }
let add_context t ~step = { steps = Info.create_s step :: t.steps; error = t.error }
let init error ~step = { steps = [ Info.create_s step ]; error }
