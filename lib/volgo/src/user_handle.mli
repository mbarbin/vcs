(*_******************************************************************************)
(*_  Volgo - a Versatile OCaml Library for Git Operations                       *)
(*_  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
(*_                                                                             *)
(*_  This file is part of Volgo.                                                *)
(*_                                                                             *)
(*_  Volgo is free software; you can redistribute it and/or modify it under     *)
(*_  the terms of the GNU Lesser General Public License as published by the     *)
(*_  Free Software Foundation either version 3 of the License, or any later     *)
(*_  version, with the LGPL-3.0 Linking Exception.                              *)
(*_                                                                             *)
(*_  Volgo is distributed in the hope that it will be useful, but WITHOUT ANY   *)
(*_  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*_  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*_  the file `NOTICE.md` at the root of this repository for more details.      *)
(*_                                                                             *)
(*_  You should have received a copy of the GNU Lesser General Public License   *)
(*_  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*_  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*_******************************************************************************)

(** A user handle, such as user pseudonym on GitHub, used in CR comments, etc.

    Unlike {!type:User_name.t}, a user handle does not have spaces. A common
    practice is to use the users's login on GitHub, which means we inherit
    already the uniqueness enforced by GitHub.

    Example: [User_handle.v "jdoe"].

    It is worth noting that user handles are usually not used directly by the
    version control. Indeed, Git will use [user.name] from the user's config,
    which includes the full first name and last name, including spaces etc.
    This module is part of the [Vcs] library for convenience. *)

type t

include Container_key.S with type t := t
include Validated_string.S with type t := t
