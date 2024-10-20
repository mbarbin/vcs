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

(** The type of errors raised by [Vcs].

    Under the hood, it is lazily constructed human-readable information which
    also carry some context (a sort of a high level stack trace manipulated by
    the programmers of Vcs).

    It is not meant to be matched on, but rather to be printed on stderr (or
    perhaps logged). *)
type t

(** [sexp_of_t t] forces the lazy message, and allow printing the information
    contained by [t]. *)
val sexp_of_t : t -> Sexp.t

(** [to_string_hum t] is a convenience wrapper around [t |> sexp_of_t |> Sexp.to_string_hum]. *)
val to_string_hum : t -> string

val error_string : string -> t
val create_s : Sexp.t -> t
val of_exn : exn -> t

(** Add a step of context into the stack trace contained by the error. *)
val add_context : t -> step:Sexp.t -> t

(** This is useful if you are starting from an [Sexp.t] initially with an
    initial step. *)
val init : Sexp.t -> step:Sexp.t -> t

module Private : sig
  module Non_raising_M : sig
    type nonrec t = t [@@deriving sexp_of]

    val to_err : t -> t
    val of_err : t -> t
  end

  module View : sig
    type t =
      { steps : Sexp.t list
      ; error : Sexp.t
      }
  end

  val view : t -> View.t

  module Vcs_base : sig
    (** Inject [t] into [Base.Error.t]. This is useful if you'd like to use [Vcs]
        inside the [Or_error] monad. *)
    val to_error : t -> Error.t

    (** Create an error with no initial step. *)
    val of_error : Error.t -> t
  end
end
