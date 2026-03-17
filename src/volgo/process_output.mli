(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Manipulating the output of process run by vcs and backends.

    This module is used to break a dependency cycle. It serves under the hood
    for the implementation of the types that are exported as [Vcs.Git.Output] and
    [Vcs.Hg.Output], although for added type safety, these 2 types are not
    exported as being equal. *)

type t =
  { exit_code : int
  ; stdout : string
  ; stderr : string
  }

val sexp_of_t : t -> Sexp.t

module Private : sig
  (** Exported for use by Git and Hg outputs. *)

  val of_process_output : t -> t
end
