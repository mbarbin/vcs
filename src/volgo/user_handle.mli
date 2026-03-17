(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** A user handle, such as user pseudonym on GitHub, used in CR comments, etc.

    Unlike {!type:User_name.t}, a user handle does not have spaces. A common
    practice is to use the users's login on GitHub, which means we inherit
    already the uniqueness enforced by GitHub.

    Example: [User_handle.v "jdoe"].

    It is worth noting that user handles are usually not used directly by the
    version control. Indeed, Git will use [user.name] from the user's config,
    which includes the full first name and last name, including spaces etc.
    This module is part of the [Vcs] library for convenience. *)

type t (** @canonical Volgo.Vcs.User_handle.t *)

include Container_key.S with type t := t
include Validated_string.S with type t := t
