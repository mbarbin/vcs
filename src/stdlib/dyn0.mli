(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

include module type of struct
  include Dyn
end

val inline_record : string -> (string * Dyn.t) list -> Dyn.t
val to_sexp : Dyn.t -> Sexplib0.Sexp.t

(** A JSON-like type, structurally compatible with [Yojson.Basic.t] without
    adding the dependency. *)
type json =
  [ `Null
  | `Bool of bool
  | `Int of int
  | `Float of float
  | `String of string
  | `Assoc of (string * json) list
  | `List of json list
  ]

(** Convert a dynamic value to JSON. *)
val to_json : Dyn.t -> json
