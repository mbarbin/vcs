(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Returns the parts of a string split by the separator " => ". We specialize
    for the only patterns that matter for the parsing logic. *)

type t =
  | Empty
  | One of string
  | Two of string * string
  | More_than_two

val to_dyn : t -> Dyn.t
val split : string -> t
