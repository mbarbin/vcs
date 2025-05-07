(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
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

type t = Err.t [@@deriving sexp_of]

let to_string_hum = Err.to_string_hum
let create_s sexp = Err.create [ Err.sexp sexp ] [@coverage off]
let error_string str = Err.create [ Pp.text str ] [@coverage off]
let of_exn = Err.of_exn
let add_context t ~step = Err.add_context t [ Err.sexp step ] [@coverage off]

let init error ~step =
  Err.add_context (Err.create [ Err.sexp error ]) [ Err.sexp step ] [@coverage off]
;;

module Private = struct
  module Non_raising_M = struct
    type nonrec t = t

    let sexp_of_t = sexp_of_t
    let to_err t = t
    let of_err t = t
  end
end
