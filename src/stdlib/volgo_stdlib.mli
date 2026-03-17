(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Extending [Stdlib] for use in the project.

    {1 Internal Library - Not for External Use}

    This library is meant to be an internal component of the Volgo project. It
    is shared across multiple OCaml packages within the project. We have not
    found a way to mark it as private in the dune build system, but it should be
    treated as private.

    {b Warning:} In particular, this library is not intended for use outside of
    the Volgo project. Its interface is subject to breaking changes at any time,
    without following semver or any other stability and backward compatibility
    guidelines. *)

include module type of struct
  include Stdlib0
end
