(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Common process interfaces used in [Vcs].

    This file is configured in [dune] as an interface only file, so we don't need to
    duplicate the interfaces it contains into an [ml] file. *)

module type S = sig
  (** Helpers to wrap process outputs. *)

  type process_output
  type 'a result

  val exit0 : process_output -> unit result
  val exit0_and_stdout : process_output -> string result

  (** A convenient wrapper to write exhaustive match on a result conditioned by
      a list of accepted exit codes. If the exit code is not part of the
      accepted list, the function takes care of returning an error of the
      expected result type. *)
  val exit_code : process_output -> accept:(int * 'a) list -> 'a result
end
