(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

open! Stdlib_compat
include ListLabels

let sexp_of_t = Sexplib0.Sexp_conv.sexp_of_list
let concat_map t ~f = concat_map ~f t
let dedup_and_sort t ~compare = sort_uniq t ~cmp:compare

let hd = function
  | [] -> None
  | hd :: _ -> Some hd
;;

let filter_opt t = filter_map t ~f:Fun.id
let find t ~f = find_opt t ~f
let find_map t ~f = find_map ~f t
let fold t ~init ~f = fold_left ~f ~init t
let iter t ~f = iter t ~f
let map t ~f = map ~f t
let mapi t ~f = mapi ~f t
let sort t ~compare = sort t ~cmp:compare
let count t ~f = fold t ~init:0 ~f:(fun acc e -> acc + if f e then 1 else 0)
