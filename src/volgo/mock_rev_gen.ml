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

module T = struct
  [@@@coverage off]

  type t =
    { name : string
    ; mutable counter : int
    }

  let to_dyn { name; counter } =
    Dyn.record [ "name", Dyn.string name; "counter", Dyn.int counter ]
  ;;

  let sexp_of_t t = Dyn.to_sexp (to_dyn t)
end

include T

let create ~name = { name; counter = 0 }

let next (t : t) =
  let i = t.counter in
  t.counter <- i + 1;
  let seed = Printf.sprintf "%d virtual-rev %s %d" i t.name i in
  let hex = seed |> Digest.string |> Digest.to_hex in
  let rev = String.init 40 ~f:(fun i -> hex.[i mod String.length hex]) in
  Rev.v rev
;;
