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
    [Eio] and {!module:Vcs_git_cli}.

    This implementation is based on the [git] command line tool. We run it as an
    external program within an [Eio] environment, producing the right command line
    invocation and parsing the output to produce a typed version of the expected
    results with [Vcs_git_cli]. Note that [git] must be found in the PATH of the
    running environment. *)

type 'a t = ([> Vcs_git_cli.Trait.t ] as 'a) Vcs.t

(** This is a convenient type alias that may be used to designate a provider
    with the exact list of traits supported by this implementation. *)
type t' = Vcs_git_cli.Trait.t t

(** [create ~env] creates a [vcs] value that can be used by the {!module:Vcs}
    library. *)
val create : env:< fs : _ Eio.Path.t ; process_mgr : _ Eio.Process.mgr ; .. > -> _ t

(** The implementation of the provider is exported for convenience. Casual
    users should prefer using [Vcs] directly. *)
module Impl : sig
  type t

  val create : env:< fs : _ Eio.Path.t ; process_mgr : _ Eio.Process.mgr ; .. > -> t

  (** {1 Provider interfaces} *)

  module Add : Vcs.Trait.Add.S with type t := t
  module Branch : Vcs.Trait.Branch.S with type t := t
  module Commit : Vcs.Trait.Commit.S with type t := t
  module Config : Vcs.Trait.Config.S with type t := t
  module File_system : Vcs.Trait.File_system.S with type t := t
  module Git : Vcs.Trait.Git.S with type t := t
  module Init : Vcs.Trait.Init.S with type t := t
  module Log : Vcs.Trait.Log.S with type t := t
  module Ls_files : Vcs.Trait.Ls_files.S with type t := t
  module Name_status : Vcs.Trait.Name_status.S with type t := t
  module Num_status : Vcs.Trait.Num_status.S with type t := t
  module Refs : Vcs.Trait.Refs.S with type t := t
  module Rev_parse : Vcs.Trait.Rev_parse.S with type t := t
  module Show : Vcs.Trait.Show.S with type t := t
end
