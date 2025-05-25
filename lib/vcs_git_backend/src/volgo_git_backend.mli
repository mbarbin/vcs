(*_******************************************************************************)
(*_  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*_  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
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

(** [Volgo_git_backend] is a helper library to build git backends for the [Vcs]
    library based on the [Git] cli.

    Given the ability to run a [git] process, [Volgo_git_backend] knows what
    command to run, how to parse its output and how to interpret its exit code
    to turn it into a typed result.

    [Volgo_git_backend] is not meant to be used directly by a user. Rather it is
    one of the building blocks involved in creating a git backend for the [Vcs]
    library.

    [Volgo_git_backend] has currently two instantiations as part of its
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
  (** The list of traits that are implemented in [Volgo_git_backend]. *)

  class type t = object
    inherit Vcs.Trait.add
    inherit Vcs.Trait.branch
    inherit Vcs.Trait.commit
    inherit Vcs.Trait.config
    inherit Vcs.Trait.file_system
    inherit Vcs.Trait.git
    inherit Vcs.Trait.init
    inherit Vcs.Trait.log
    inherit Vcs.Trait.ls_files
    inherit Vcs.Trait.name_status
    inherit Vcs.Trait.num_status
    inherit Vcs.Trait.refs
    inherit Vcs.Trait.rev_parse
    inherit Vcs.Trait.show
  end
end

(** Create a backend based on a runtime. *)

module type S = sig
  type t

  class c : t -> Trait.t

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

module Make (Runtime : Runtime.S) : S with type t = Runtime.t

(** {2 Individual Providers}

    The rest of the modules are functors that are parametrized by your
    [Runtime]. Given the ability to run a git command line, this modules return
    a backend implementation for each of the traits defined by the [Vcs]
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
