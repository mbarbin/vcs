(*_******************************************************************************)
(*_  Vcs - a versatile OCaml library for Git interaction                        *)
(*_  Copyright (C) 2024 Mathieu Barbin <mathieu.barbin@gmail.com>               *)
(*_                                                                             *)
(*_  This file is part of Vcs.                                                  *)
(*_                                                                             *)
(*_  Vcs is free software; you can redistribute it and/or modify it under       *)
(*_  the terms of the GNU Lesser General Public License as published by the     *)
(*_  Free Software Foundation either version 3 of the License, or any later     *)
(*_  version, with the LGPL-3.0 Linking Exception.                              *)
(*_                                                                             *)
(*_  Vcs is distributed in the hope that it will be useful, but WITHOUT ANY     *)
(*_  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*_  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*_  the file `NOTICE.md` at the root of this repository for more details.      *)
(*_                                                                             *)
(*_  You should have received a copy of the GNU Lesser General Public License   *)
(*_  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*_  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*_******************************************************************************)

(** The root of a version control repository that is expected to exists on the
    local file system.

    This is a wrapper around [Absolute_path.t] to increase type safety. *)

type t [@@deriving compare, equal, hash, sexp_of]

include Validated_string.S with type t := t

val of_absolute_path : Absolute_path.t -> t
val to_absolute_path : t -> Absolute_path.t

(** Given an absolute path that is under this repository, returns its relative
    repo path. This returns an [Error _] if the supplied absolute path doesn't
    point to a path within this repository. *)
val relativize : t -> Absolute_path.t -> Path_in_repo.t Or_error.t

(** This is useful to access file on the file system. *)
val append : t -> Path_in_repo.t -> Absolute_path.t
