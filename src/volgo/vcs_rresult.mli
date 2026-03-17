(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** An [Vcs] API in the style of
    {{:https://erratique.ch/software/rresult/doc/Rresult/index.html#usage} Rresult}. *)

type err = [ `Vcs of Err.t ]

val sexp_of_err : err -> Sexp.t

type 'a t = ('a, err) Result.t

val sexp_of_t : ('a -> Sexp.t) -> 'a t -> Sexp.t

type 'a result = 'a t

(** {1 Utils}

    This part exposes the functions prescribed by the
    {{:https://erratique.ch/software/rresult/doc/Rresult/index.html#usage} Rresult}
    usage design guidelines. *)

val pp_error : Format.formatter -> [ `Vcs of Err.t ] -> unit
val open_error : 'a result -> ('a, [> `Vcs of Err.t ]) Result.t
val error_to_msg : 'a result -> ('a, [ `Msg of string ]) Result.t

(** {1 Non raising API}

    The individual functions are documented the {!module:Vcs} module. *)

include Non_raising.S with type 'a t := 'a Vcs0.t and type 'a result := 'a result
