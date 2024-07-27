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

(** Implementation of a git provider for the {!module:Vcs} library, based on
    [Stdlib] and {!module:Vcs_git_cli}.

    This implementation is based on the [git] command line tool. We run it as an
    external program with utils from [Stdlib] and [Unix], producing the right
    command line invocation and parsing the output to produce a typed version of
    the expected results with [Vcs_git_cli]. Note that [git] must be found in the
    PATH of the running environment. *)

type 'a t = ([> Vcs_git_cli.Trait.t ] as 'a) Vcs.t

(** This is a convenient type alias that may be used to designate a provider
    with the exact list of traits supported by this implementation. *)
type t' = Vcs_git_cli.Trait.t t

val create : unit -> _ t
