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

type t = bool array

let sexp_of_t t =
  let b = Bytes.create (Array.length t) in
  Array.iteri t ~f:(fun i x -> Bytes.set b i (if x then '1' else '0'));
  Sexp.Atom (Bytes.to_string b)
;;

let create ~len value : t = Array.create ~len value
let length = Array.length
let set = Array.set
let get = Array.get
let reset t value = Array.fill t ~pos:0 ~len:(Array.length t) value
let copy = Array.copy
let filter_mapi = Array.filter_mapi

let bw_and_in_place ~mutates other =
  if Array.length mutates <> Array.length other
  then invalid_arg "Bit_vector.bw_and_in_place" [@coverage off];
  for i = 0 to Array.length mutates - 1 do
    mutates.(i) <- mutates.(i) && other.(i)
  done
;;
