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

(** This module implements the handling of running the git and hg processes in a
    blocking fashion. *)

module type S = sig
  type t

  val create : env:< fs : _ Eio.Path.t ; process_mgr : _ Eio.Process.mgr ; .. > -> t

  (** {1 I/O} *)

  include Vcs.Trait.File_system.S with type t := t

  (** {1 Running the git/hg command line} *)

  type process_output

  val vcs_cli
    :  ?env:string array
    -> t
    -> cwd:Absolute_path.t
    -> args:string list
    -> f:(process_output -> ('a, Err.t) Result.t)
    -> ('a, Err.t) Result.t
end

module type M = sig
  val executable_basename : string

  module Output : sig
    type t

    module Private : sig
      val of_process_output : Vcs.Private.Process_output.t -> t
    end
  end
end

module Make (M : M) : S with type process_output := M.Output.t
