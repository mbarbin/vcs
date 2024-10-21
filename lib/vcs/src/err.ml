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
  { steps : Sexp.t list
  ; error : Sexp.t
  }
[@@deriving sexp_of]

let sexp_of_t ({ steps; error } as t) = if List.is_empty steps then error else sexp_of_t t
let to_string_hum t = t |> sexp_of_t |> Sexp.to_string_hum
let create_s sexp = { steps = []; error = sexp }
let error_string str = create_s (Sexp.Atom str)
let of_exn exn = create_s (sexp_of_exn exn)
let add_context t ~step = { steps = step :: t.steps; error = t.error }
let init error ~step = { steps = [ step ]; error }

module Private = struct
  module Non_raising_M = struct
    type nonrec t = t

    let sexp_of_t = sexp_of_t
    let to_err t = t
    let of_err t = t
  end

  module View = struct
    type nonrec t = t =
      { steps : Sexp.t list
      ; error : Sexp.t
      }
  end

  let view t = t

  module Vcs_base = struct
    let to_error t =
      Error.create_s
        (match view t with
         | { steps = []; error } -> error
         | { steps = _ :: _; error = _ } -> sexp_of_t t)
    ;;

    let of_error error = create_s (Error.sexp_of_t error)
  end
end
