(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

module type S = sig
  type t

  (** Given that [t = string] in the implementation, this function is just the
      identity. *)
  val to_string : t -> string

  (** [of_string str] returns [Ok str] if [X.invariant str = true], and an error
      otherwise. This is meant to be used to validate untrusted entries. *)
  val of_string : string -> (t, [ `Msg of string ]) Result.t

  (** [v str] is a convenient wrapper to build a [t] or raise
      [Invalid_argument]. This is typically handy for applying on trusted
      literals. *)
  val v : string -> t
end

module type X = sig
  (** The module name is used for error messages only. *)
  val module_name : string

  (** This is the validation function that should be run on the untrusted input
      string. Return [true] on valid input.

      By construction, [invariant t = true] is an invariant of any value of type
      [t], since it is verified during [of_string _]. *)
  val invariant : string -> bool
end
