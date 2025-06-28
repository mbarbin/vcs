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

type t = Fast_bitvector.t

let sexp_of_t t = Sexp.Atom (Fast_bitvector.Bit_zero_first.to_string t)

let create ~len value =
  let t = Fast_bitvector.create ~len in
  let () = if value then Fast_bitvector.set_all t in
  t
;;

let length = Fast_bitvector.length
let set = Fast_bitvector.set
let clear = Fast_bitvector.clear
let get = Fast_bitvector.get
let clear_all = Fast_bitvector.clear_all
let copy = Fast_bitvector.copy

let bitwise_and_in_place ~dst va vb =
  let len = length dst in
  if len <> length va || len <> length vb
  then invalid_arg "Bit_vector.bitwise_and_in_place" [@coverage off];
  Fast_bitvector.Set.inter ~dst va vb;
  ()
;;
