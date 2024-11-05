(*_******************************************************************************)
(*_  Vcs - a Versatile OCaml Library for Git Operations                         *)
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

(** [Vcs_git_provider] is a helper library to build git providers for the [Vcs]
    library.

    Given the ability to run a [git] process, [Vcs_git_provider] knows what
    command to run, how to parse its output and how to interpret its exit code
    to turn it into a typed result.

    [Vcs_git_provider] is not meant to be used directly by a user. Rather it is
    one of the building blocks involved in creating a git provider for the [Vcs]
    library.

    [Vcs_git_provider] has currently two instantiations as part of its
    distribution (packaged separately to keep the dependencies isolated).

    - One based on the [Eio] runtime
    - One based on the [Stdlib.Unix] runtime, for blocking programs.

    We make some efforts to rely on stable and machine friendly output when one
    is available and documented in the [git] cli man pages, but this is not
    always possible, so the implementation uses some kind of best effort
    strategy. Also, to avoid running into [git version] issues, we're trying to
    rely on git commands that have been there for a while. *)

module Runtime = Runtime

(** {1 Providers of Vcs Traits} *)

module Trait : sig
  (** The list of traits that are implemented in [Vcs_git_provider]. *)
  type t =
    [ Vcs.Trait.add
    | Vcs.Trait.branch
    | Vcs.Trait.commit
    | Vcs.Trait.config
    | Vcs.Trait.file_system
    | Vcs.Trait.git
    | Vcs.Trait.init
    | Vcs.Trait.log
    | Vcs.Trait.ls_files
    | Vcs.Trait.name_status
    | Vcs.Trait.num_status
    | Vcs.Trait.refs
    | Vcs.Trait.rev_parse
    | Vcs.Trait.show
    ]
end

(** Create a provider based on a runtime. *)
module Make (Runtime : Runtime.S) : sig
  type t = Runtime.t

  val provider : unit -> (t, [> Trait.t ]) Provider.t

  (** {1 Individual implementations} *)

  module Add : Vcs.Trait.Add.S with type t = t
  module Branch : Vcs.Trait.Branch.S with type t = t
  module Commit : Vcs.Trait.Commit.S with type t = t
  module Config : Vcs.Trait.Config.S with type t = t
  module File_system : Vcs.Trait.File_system.S with type t = t
  module Git : Vcs.Trait.Git.S with type t = t
  module Init : Vcs.Trait.Init.S with type t = t
  module Log : Vcs.Trait.Log.S with type t = t
  module Ls_files : Vcs.Trait.Ls_files.S with type t = t
  module Name_status : Vcs.Trait.Name_status.S with type t = t
  module Num_status : Vcs.Trait.Num_status.S with type t = t
  module Refs : Vcs.Trait.Refs.S with type t = t
  module Rev_parse : Vcs.Trait.Rev_parse.S with type t = t
  module Show : Vcs.Trait.Show.S with type t = t
end

(** {2 Individual Providers}

    The rest of the modules are functors that are parametrized by your
    [Runtime]. Given the ability to run a git command line, this modules return
    a provider implementation for each of the traits defined by the [Vcs]
    library. The individual functors are exposed for convenience. *)

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

(** {1 Tests}

    Exported for tests. *)
module Private : sig
  module Munged_path = Munged_path
end
