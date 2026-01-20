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

module type H = sig
  type t

  val to_dyn : t -> Dyn.t
  val hash : t -> int
  val seeded_hash : int -> t -> int
end

let run
      (type a)
      (module V : H with type t = a)
      (module V_base : Ppx_hash_lib.Hashable.S with type t = a)
      values
  =
  let test_hash (t : a) =
    let stdlib_hash = Stdlib.Hashtbl.hash t in
    let vcs_hash = V.hash t in
    let vcs_base_hash = V_base.hash t in
    print_dyn
      (Dyn.Tuple
         [ Dyn.record [ "value", V.to_dyn t ]
         ; Dyn.record
             [ "stdlib_hash", stdlib_hash |> Dyn.int
             ; "vcs_hash", vcs_hash |> Dyn.int
             ; "vcs_base_hash", vcs_base_hash |> Dyn.int
             ]
         ])
  in
  let test_fold (t : a) ~seed =
    let stdlib_hash = Stdlib.Hashtbl.seeded_hash seed t in
    let vcs_hash = V.seeded_hash seed t in
    let vcs_base_hash = Hash.run ~seed V_base.hash_fold_t t in
    print_dyn
      (Dyn.Tuple
         [ Dyn.record [ "value", V.to_dyn t; "seed", seed |> Dyn.int ]
         ; Dyn.record
             [ "stdlib_hash", stdlib_hash |> Dyn.int
             ; "vcs_hash", vcs_hash |> Dyn.int
             ; "vcs_base_hash", vcs_base_hash |> Dyn.int
             ]
         ])
  in
  List.iter values ~f:(fun t ->
    test_hash t;
    test_fold t ~seed:0;
    test_fold t ~seed:42)
;;
