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

(** A builtin [File_system] trait used for convenience.

    Although this does not relate to git, having the ability to do basic file
    system operations in vcs directly allows users of vcs to write logic
    containing simple I/O operations without having to commit to a particular
    backend. *)

type load_file_method = path:Absolute_path.t -> (File_contents.t, Err.t) Result.t

type save_file_method =
  ?perms:int
  -> unit
  -> path:Absolute_path.t
  -> file_contents:File_contents.t
  -> (unit, Err.t) Result.t

type read_dir_method = dir:Absolute_path.t -> (Fsegment.t list, Err.t) Result.t

module type S = sig
  type t

  val load_file : t -> load_file_method
  val save_file : t -> save_file_method
  val read_dir : t -> read_dir_method
end

class type t = object
  method load_file : load_file_method
  method save_file : save_file_method
  method read_dir : read_dir_method
end

module Make (X : S) : sig
  class c : X.t -> object
    inherit t
  end
end
