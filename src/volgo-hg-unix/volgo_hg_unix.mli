(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Implementation of a Mercurial backend for the {!module:Volgo.Vcs} library,
    based on [Stdlib] and {!module:Volgo_hg_backend}.

    This implementation is based on the [hg] command line tool. We run it as an
    external program with utils from [Stdlib] and [Unix], producing the right
    command line invocation and parsing the output to produce a typed version of
    the expected results with [Volgo_hg_backend]. Note that [hg] must be found
    in the PATH of the running environment. *)

(** This is a convenient type alias that may be used to designate a backend
    with the exact list of traits supported by this implementation. *)
type t = Volgo_hg_backend.Trait.t Vcs.t

(** When [create] is called, the environment variable ["PATH"] is read to
    resolve the executable whose basename is "hg". Subsequent calls to that
    [vcs] value will execute that resolved path, unless a ["PATH"] variable is
    passed as an override to a call in particular, via the [env] variable of
    [Vcs.hg ?env]). *)
val create : unit -> t

(** The implementation of the backend is exported for convenience and tests.
    Casual users should prefer using [Vcs] directly. *)
module Impl : Volgo_hg_backend.S with type t = Runtime.t

(** {1 Runtime}

    Exposed if you need to extend it. *)

module Runtime = Runtime
