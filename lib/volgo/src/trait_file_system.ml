(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
(*                                                                             *)
(*  This file is part of Vcs.                                                  *)
(*                                                                             *)
(*  Vcs is free software; you can redistribute it and/or modify it under       *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Vcs is distributed in the hope that it will be useful, but WITHOUT ANY     *)
(*  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*  the file `NOTICE.md` at the root of this repository for more details.      *)
(*                                                                             *)
(*  You should have received a copy of the GNU Lesser General Public License   *)
(*  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*******************************************************************************)

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

module Make (X : S) = struct
  class c (t : X.t) =
    object
      method load_file = X.load_file t
      method save_file = X.save_file t
      method read_dir = X.read_dir t
    end
end
