(*_******************************************************************************)
(*_  Volgo - a Versatile OCaml Library for Git Operations                       *)
(*_  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
(*_                                                                             *)
(*_  This file is part of Volgo.                                                *)
(*_                                                                             *)
(*_  Volgo is free software; you can redistribute it and/or modify it under     *)
(*_  the terms of the GNU Lesser General Public License as published by the     *)
(*_  Free Software Foundation either version 3 of the License, or any later     *)
(*_  version, with the LGPL-3.0 Linking Exception.                              *)
(*_                                                                             *)
(*_  Volgo is distributed in the hope that it will be useful, but WITHOUT ANY   *)
(*_  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*_  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*_  the file `NOTICE.md` at the root of this repository for more details.      *)
(*_                                                                             *)
(*_  You should have received a copy of the GNU Lesser General Public License   *)
(*_  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*_  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*_******************************************************************************)

(** Manipulating the output of processes run by vcs and backends - typically
    the ["git"] command. *)

module Output : sig
  type t = Git_output0.t =
    { exit_code : int
    ; stdout : string
    ; stderr : string
    }
  [@@deriving sexp_of]
end

(** This is the interface commonly used by raising and non-raising helper
    modules, such as {!module:Vcs.Git}, [Volgo_base.Vcs.Git.Or_error],
    {!module:Vcs.Git.Result}, {!module:Vcs.Git.Rresult}, and custom ones built
    with {!module:Vcs.Git.Non_raising.Make}. [S] is parametrized by the result
    type returned by the helpers. *)
module type S = Vcs_interface.Process_S

(** The interface exposed at the top level of this module are helpers that
    return direct results, or raise [Err.E]. This module is exported to users
    as [Vcs.Git].

    The helpers are suitable for use in combination with the {!val:Vcs.git}
    function, which will take care of wrapping the exception with useful
    context, before re-raising it. *)
include S with type 'a result := 'a

module Non_raising : sig
  (** A functor to build non raising helpers based on a custom error type.

      In addition to {!module:Vcs.Git.Result}, {!module:Vcs.Git.Rresult} and
      [Volgo_base.Vcs.Git.Or_error], we provide this functor to create a [Git.S]
      interface based on a custom error type of your choice. *)

  module type M = Vcs_interface.Error_S

  module Make (M : M) : S with type 'a result := ('a, M.t) Result.t
end

module Rresult : S with type 'a result := ('a, Vcs_rresult0.t) Result.t
module Result : S with type 'a result := ('a, Err.t) Result.t
