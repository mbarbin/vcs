(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

module Make (Runtime : Runtime.S) : sig
  type t = Runtime.t

  include Vcs.Trait.Num_status.S with type t := t
end

(** {1 Git output parsing}

    This is exposed for tests and low-level usage. *)

(** Parsing the output of ["git diff --num-status REV..REV"]. *)
val parse_lines_exn : lines:string list -> Vcs.Num_status.t

(** Parse only one line. Exposed for tests. *)
val parse_line_exn : line:string -> Vcs.Num_status.Change.t
