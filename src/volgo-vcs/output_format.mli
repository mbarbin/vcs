(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Output format selector for CLI commands.

    - [Dyn]: Dynamic values that looks like OCaml literals
    - [Json]: JSON format suitable for parsing by other tools
    - [Sexp]: S-expression format *)

type t =
  | Dyn
  | Json
  | Sexp

include Command.Enumerated_stringable with type t := t
