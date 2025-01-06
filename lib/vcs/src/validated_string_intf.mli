(*_******************************************************************************)
(*_  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*_  Copyright (C) 2024 Mathieu Barbin <mathieu.barbin@gmail.com>               *)
(*_                                                                             *)
(*_  This file is part of Vcs.                                                  *)
(*_                                                                             *)
(*_  Vcs is free software; you can redistribute it and/or modify it under       *)
(*_  the terms of the GNU Lesser General Public License as published by the     *)
(*_  Free Software Foundation either version 3 of the License, or any later     *)
(*_  version, with the LGPL-3.0 Linking Exception.                              *)
(*_                                                                             *)
(*_  Vcs is distributed in the hope that it will be useful, but WITHOUT ANY     *)
(*_  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*_  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*_  the file `NOTICE.md` at the root of this repository for more details.      *)
(*_                                                                             *)
(*_  You should have received a copy of the GNU Lesser General Public License   *)
(*_  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*_  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*_******************************************************************************)

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
