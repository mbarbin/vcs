(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

module Make (Runtime : Runtime.S) : sig
  type t = Runtime.t

  include Vcs.Trait.Log.S with type t := t
end

(** {1 Git output parsing}

    This is exposed for tests and low-level usage. *)

(** Parsing the output of each line of ["git log --pretty=format:'%H %P'"]. *)
val parse_log_line_exn : line:string -> Vcs.Log.Line.t
