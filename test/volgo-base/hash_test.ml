(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

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
