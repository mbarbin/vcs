(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** An [Vcs] API based on [Base.Or_error]. *)

type err = Error.t

val sexp_of_err : err -> Sexp.t

type 'a t = 'a Or_error.t

val sexp_of_t : ('a -> Sexp.t) -> 'a t -> Sexp.t

(** {1 Non raising API}

    The individual functions are documented the {!module:Vcs} module. *)

include Vcs.Non_raising.S with type 'a t := 'a Vcs.t and type 'a result := 'a t
