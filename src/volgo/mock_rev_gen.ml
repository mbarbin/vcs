(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

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
