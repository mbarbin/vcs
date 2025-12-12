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

(** A [platform] in vcs' terminology is an online software development service
    where users host repositories, such as ["GitHub"].

    This type is used to implement utilities for interacting with various
    platforms, for example to clone repositories.

    The list of supported platforms may grow over time. *)

(** @canonical Volgo.Vcs.Platform.t *)
type t =
  | Bitbucket
  | Codeberg
  | GitHub
  | GitLab
  | Sourcehut

include Container_key.S with type t := t

val all : t list

(** A string representing the platform, using the styled capitalization of the
    variant constructor. For example, ["GitHub"] is typically spelled with an
    uppercase 'H'. This is suitable for inclusion into error messages, user
    facing logs, etc. *)
val to_string : t -> string
