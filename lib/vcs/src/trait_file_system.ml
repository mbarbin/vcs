(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024 Mathieu Barbin <mathieu.barbin@gmail.com>               *)
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

module type S = sig
  type t

  val load_file : t -> path:Absolute_path.t -> (File_contents.t, Err.t) Result.t

  val save_file
    :  ?perms:int
    -> t
    -> path:Absolute_path.t
    -> file_contents:File_contents.t
    -> (unit, Err.t) Result.t

  val read_dir : t -> dir:Absolute_path.t -> (Fsegment.t list, Err.t) Result.t
end

class type t = object
  method load_file : path:Absolute_path.t -> (File_contents.t, Err.t) Result.t

  method save_file :
    ?perms:int
    -> unit
    -> path:Absolute_path.t
    -> file_contents:File_contents.t
    -> (unit, Err.t) Result.t

  method read_dir : dir:Absolute_path.t -> (Fsegment.t list, Err.t) Result.t
end

module Make (X : S) = struct
  class c (t : X.t) =
    object
      method load_file = X.load_file t

      method save_file ?perms () ~path ~file_contents =
        X.save_file ?perms t ~path ~file_contents

      method read_dir = X.read_dir t
    end
end

let make (type a) (module X : S with type t = a) (t : a) =
  let module M = Make (X) in
  new M.c t
;;
