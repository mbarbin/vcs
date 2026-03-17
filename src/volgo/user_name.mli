(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** User name information as specified by the Git config user.name value.

    Usually, this includes the full first name and last name, such as
    [User_name.v "John Doe"]. This is not to be conflated with the
    {!module:User_handle}, which are used as GitHub logins and other contexts. *)

type t

include Container_key.S with type t := t
include Validated_string.S with type t := t
