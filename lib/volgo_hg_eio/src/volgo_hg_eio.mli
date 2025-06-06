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

(** Implementation of a Mercurial backend for the {!module:Volgo.Vcs} library,
    based on [Eio] and {!module:Volgo_hg_backend}.

    This implementation is based on the [hg] command line tool. We run it as an
    external program within an [Eio] environment, producing the right command line
    invocation and parsing the output to produce a typed version of the expected
    results with [Volgo_hg_backend]. Note that [hg] must be found in the PATH of the
    running environment. *)

(** This is a convenient type alias that may be used to designate a backend with
    the exact list of traits supported by this implementation. *)
type t = Volgo_hg_backend.Trait.t Vcs.t

(** [create ~env] creates a [vcs] value that can be used by the [Vcs]
    library. *)
val create : env:< fs : _ Eio.Path.t ; process_mgr : _ Eio.Process.mgr ; .. > -> t

(** The implementation of the backend is exported for convenience and tests.
    Casual users should prefer using [Vcs] directly. *)
module Impl : Volgo_hg_backend.S with type t = Runtime.t

(** {1 Runtime}

    Exposed if you need to extend it. *)

module Runtime = Runtime
