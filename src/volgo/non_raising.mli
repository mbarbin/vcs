(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** A functor to build non raising interfaces for [Vcs] based on a custom result
    type.

    In addition to [Volgo_base.Vcs.Or_error] and {!module:Vcs.Result}, we provide
    this functor to create a [Vcs] interface based on a custom error type of
    your choice. See also {!module:Vcs.Git.Non_raising.Make}. *)

module type M = Error_intf.S
module type S = Vcs_intf.S

module Make (M : M) :
  S with type 'a t := 'a Vcs0.t and type 'a result := ('a, M.t) Result.t
