(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

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
