(*_******************************************************************************)
(*_  Vcs - a versatile OCaml library for Git interaction                        *)
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

(** A functor to build non raising interfaces for [Vcs] based on a custom result
    type.

    In addition to {!module:Vcs.Or_error} and {!module:Vcs.Result}, we provide
    this functor to create a [Vcs] interface based on a custom result type of
    your choice. See also {!module:Vcs.Git.Non_raising.Make}. *)

module type M = Vcs_interface.Error_S
module type S = Vcs_interface.S

module Make (M : M) :
  S with type 'a t := 'a Vcs0.t and type 'a result := ('a, M.err) Result.t
