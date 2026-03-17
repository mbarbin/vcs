(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Number of lines involved in a change.

    Git returns this as a pair of positive integers, which are the number of
    insertions and number of deletions. Both are a positive or null integer counting
    a number of lines. *)

(** @canonical Volgo.Vcs.Num_lines_in_diff.t *)
type t =
  { insertions : int
  ; deletions : int
  }

val to_dyn : t -> Dyn.t
val sexp_of_t : t -> Sexp.t
val compare : t -> t -> int
val equal : t -> t -> bool
val zero : t
val ( + ) : t -> t -> t
val sum : t list -> t
val is_zero : t -> bool

(** Returns a short string suitable for human consumption.
    Some examples: [["0"; "+100"; "-15"; "+1,999, -13,898"]]. *)
val to_string_hum : t -> string

(** The addition of the insertions and deletions. *)
val total : t -> int
