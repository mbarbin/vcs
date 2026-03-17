(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Utils to manipulate abstract types that are strings in their implementation. *)

module type S = Validated_string_intf.S
module type X = Validated_string_intf.X

(** [Make] returns an interface that exposes the fact that [t = string] so this
    equality can be used by other functions in the implementation. However,
    the expected pattern is that such equality is hidden by the inclusion of
    [S] in the mli of a validated string. See {!Author} for an example. *)
module Make (_ : X) : S with type t := string
