(*_******************************************************************************)
(*_  Vcs - a Versatile OCaml Library for Git Operations                         *)
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

(** A builtin [File_system] trait used for convenience.

    Although this does not relate to git, having the ability to do basic file
    system operations in vcs directly allows users of vcs to write logic
    containing simple I/O operations without having to commit to a particular
    backend. *)

module type S = sig
  type t

  (** Returns the contents of the file at the given path or an error if the file
      does not exist or is not readable. *)
  val load_file : t -> path:Absolute_path.t -> File_contents.t Or_error.t

  (** [save_file] is expected to truncate the file if it already exists. Errors
      are reserved for other cases, such as trying to write to an non existing
      directory, not having write permissions, etc. *)
  val save_file
    :  ?perms:int (** defaults to [0o666]. *)
    -> t
    -> path:Absolute_path.t
    -> file_contents:File_contents.t
    -> unit Or_error.t

  (** Returns the entries contained in the given directory, ordered increasingly
      according to [String.compare]. This must error out if [dir] is not a
      directory, or if we don't have access to it. The unix entries "." and
      ".." shall not be included in the result. *)
  val read_dir : t -> dir:Absolute_path.t -> Fsegment.t list Or_error.t
end
