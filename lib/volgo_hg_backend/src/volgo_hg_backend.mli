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

(** [Volgo_hg_backend] is a helper library to build Mercurial backends for the
    [Vcs] library based on the Mercurial cli [hg].

    Given the ability to run a [hg] process, [Volgo_hg_backend] knows what
    command to run, how to parse its output and how to interpret its exit code
    to turn it into a typed result.

    [Volgo_hg_backend] is not meant to be used directly by a user. Rather it is
    one of the building blocks involved in creating a Mercurial backend for the
    [Vcs] library.

    [Volgo_hg_backend] has currently two instantiations as part of its
    distribution (packaged separately to keep the dependencies isolated).

    - One based on the [Eio] runtime
    - One based on the [Stdlib.Unix] runtime, for blocking programs.

    We make some efforts to rely on stable and machine friendly output when one
    is available and documented in the [hg] cli man pages, but this is not
    always possible, so the implementation uses some kind of best effort
    strategy. Also, to avoid running into [hg version] issues, we're trying to
    rely on Mercurial commands that have been there for a while. *)

module Runtime = Runtime

(** {1 Providers of Vcs Traits} *)

module Trait : sig
  (** The list of traits that are implemented in [Volgo_hg_backend]. *)

  class type t = object
    inherit Vcs.Trait.add
    inherit Vcs.Trait.commit
    inherit Vcs.Trait.current_revision
    inherit Vcs.Trait.file_system
    inherit Vcs.Trait.hg
    inherit Vcs.Trait.init
    inherit Vcs.Trait.ls_files
  end
end

(** Create a backend based on a runtime. *)

module type S = sig
  type t

  class c : t -> Trait.t

  (** {1 Individual implementations} *)

  module Add : Vcs.Trait.Add.S with type t = t
  module Commit : Vcs.Trait.Commit.S with type t = t
  module Current_revision : Vcs.Trait.Current_revision.S with type t = t
  module File_system : Vcs.Trait.File_system.S with type t = t
  module Hg : Vcs.Trait.Hg.S with type t = t
  module Init : Vcs.Trait.Init.S with type t = t
  module Ls_files : Vcs.Trait.Ls_files.S with type t = t
end

module Make (Runtime : Runtime.S) : S with type t = Runtime.t

(** {2 Individual Trait Implementation}

    The rest of the modules are functors that are parametrized by your
    [Runtime]. Given the ability to run a hg command line, this modules return
    a backend implementation for each of the traits defined by the [Vcs] library
    supported by this library. The individual functors are exposed for
    convenience. *)

module Add = Add
module Commit = Commit
module Current_revision = Current_revision
module Init = Init
module Ls_files = Ls_files

(** {1 Tests}

    Exported for tests. *)
module Private : sig end
