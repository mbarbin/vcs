(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

type t = Err.t

(** Inject [t] into [Base.Error.t]. This is useful if you'd like to use [Vcs]
    inside the [Base.Or_error] monad. *)
val to_error : t -> Error.t

(** Create an error with no initial step. *)
val of_error : Error.t -> t
