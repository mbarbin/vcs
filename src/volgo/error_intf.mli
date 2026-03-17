(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Common error interfaces used in [Vcs].

    This file is configured in [dune] as an interface only file, so we don't need to
    duplicate the interfaces it contains into an [ml] file. *)

module type S = sig
  (** Interface used to build non raising interfaces to [Vcs] via
      [Vcs.Non_raising.Make]. *)

  (** [t] must represent the type of errors in your monad. *)
  type t

  val sexp_of_t : t -> Sexp.t

  (** The conversion functions you need to provide. *)

  val of_err : Err.t -> t
  val to_err : t -> Err.t
end
