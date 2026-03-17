(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** This module implements the handling of running the git and hg processes in a
    blocking fashion. *)

module type S = sig
  type t

  val create : unit -> t

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

module Private : sig
  val find_executable : path:string -> executable_basename:string -> string option
end
