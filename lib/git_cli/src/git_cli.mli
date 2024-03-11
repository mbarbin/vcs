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

(** [Git_cli] is a helper library to build git providers for the [Vcs] library.

    Given the ability to run a [git] process, [Git_cli] knows what command to
    run, how to parse its output and how to interpret its exit code to turn it
    into a typed result.

    [Git_cli] is not meant to be used directly by a user. Rather it is one of
    the building blocks involved in creating a git provider for the [Vcs]
    library.

    [Git_cli] has currently two instantiations as part of its distribution
    (packaged separately to keep the dependencies isolated).

    - One based on the [Eio] runtime
    - One based on the [Stdlib.Unix] runtime, for blocking programs.

    We make some efforts to rely on stable and machine friendly output when one
    is available and documented in the [git] cli man pages, but this is not
    always possible, so the implementation uses some kind of best effort
    strategy. Also, to avoid running into [git version] issues, we're trying to
    rely on git commands that have been there for a while. *)

module Runtime = Runtime

(** {1 Implementation of Vcs Traits}

    The rest of the modules are functors that are parametrized by your
    [Runtime]. Given the ability to run a git command line, this modules return
    a provider implementation for each of the traits defined by the [Vcs]
    library. *)

module Add = Add
module Branch = Branch
module Commit = Commit
module Config = Config
module Init = Init
module Log = Log
module Ls_files = Ls_files
module Name_status = Name_status
module Num_status = Num_status
module Refs = Refs
module Rev_parse = Rev_parse
module Show = Show

(** Exported for tests. *)
module Private : sig
  module Munged_path = Munged_path
end
