(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

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
