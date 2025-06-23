(*******************************************************************************)
(*  Volgo - a Versatile OCaml Library for Git Operations                       *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
(*                                                                             *)
(*  This file is part of Volgo.                                                *)
(*                                                                             *)
(*  Volgo is free software; you can redistribute it and/or modify it under     *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Volgo is distributed in the hope that it will be useful, but WITHOUT ANY   *)
(*  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*  the file `NOTICE.md` at the root of this repository for more details.      *)
(*                                                                             *)
(*  You should have received a copy of the GNU Lesser General Public License   *)
(*  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*******************************************************************************)

module Add = Add
module Branch = Branch
module Commit = Commit
module Config = Config
module Current_branch = Current_branch
module Current_revision = Current_revision
module Init = Init
module Log = Log
module Ls_files = Ls_files
module Name_status = Name_status
module Num_status = Num_status
module Refs = Refs
module Runtime = Runtime
module Show = Show

module Private = struct
  module Munged_path = Munged_path
end

module Trait = struct
  class type t = object
    inherit Vcs.Trait.add
    inherit Vcs.Trait.branch
    inherit Vcs.Trait.commit
    inherit Vcs.Trait.config
    inherit Vcs.Trait.current_branch
    inherit Vcs.Trait.current_revision
    inherit Vcs.Trait.file_system
    inherit Vcs.Trait.git
    inherit Vcs.Trait.init
    inherit Vcs.Trait.log
    inherit Vcs.Trait.ls_files
    inherit Vcs.Trait.name_status
    inherit Vcs.Trait.num_status
    inherit Vcs.Trait.refs
    inherit Vcs.Trait.show
  end
end

module type S = sig
  type t

  class c : t -> Trait.t

  module Add : Vcs.Trait.Add.S with type t = t
  module Branch : Vcs.Trait.Branch.S with type t = t
  module Commit : Vcs.Trait.Commit.S with type t = t
  module Config : Vcs.Trait.Config.S with type t = t
  module Current_branch : Vcs.Trait.Current_branch.S with type t = t
  module Current_revision : Vcs.Trait.Current_revision.S with type t = t
  module File_system : Vcs.Trait.File_system.S with type t = t
  module Git : Vcs.Trait.Git.S with type t = t
  module Init : Vcs.Trait.Init.S with type t = t
  module Log : Vcs.Trait.Log.S with type t = t
  module Ls_files : Vcs.Trait.Ls_files.S with type t = t
  module Name_status : Vcs.Trait.Name_status.S with type t = t
  module Num_status : Vcs.Trait.Num_status.S with type t = t
  module Refs : Vcs.Trait.Refs.S with type t = t
  module Show : Vcs.Trait.Show.S with type t = t
end

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  module Impl = struct
    module Add = Add.Make (Runtime)
    module Branch = Branch.Make (Runtime)
    module Commit = Commit.Make (Runtime)
    module Config = Config.Make (Runtime)
    module Current_branch = Current_branch.Make (Runtime)
    module Current_revision = Current_revision.Make (Runtime)
    module File_system = Runtime
    module Git = Runtime
    module Init = Init.Make (Runtime)
    module Log = Log.Make (Runtime)
    module Ls_files = Ls_files.Make (Runtime)
    module Name_status = Name_status.Make (Runtime)
    module Num_status = Num_status.Make (Runtime)
    module Refs = Refs.Make (Runtime)
    module Show = Show.Make (Runtime)
  end

  module Class = struct
    module Add = Vcs.Trait.Add.Make (Impl.Add)
    module Branch = Vcs.Trait.Branch.Make (Impl.Branch)
    module Commit = Vcs.Trait.Commit.Make (Impl.Commit)
    module Config = Vcs.Trait.Config.Make (Impl.Config)
    module Current_branch = Vcs.Trait.Current_branch.Make (Impl.Current_branch)
    module Current_revision = Vcs.Trait.Current_revision.Make (Impl.Current_revision)
    module File_system = Vcs.Trait.File_system.Make (Impl.File_system)
    module Git = Vcs.Trait.Git.Make (Impl.Git)
    module Init = Vcs.Trait.Init.Make (Impl.Init)
    module Log = Vcs.Trait.Log.Make (Impl.Log)
    module Ls_files = Vcs.Trait.Ls_files.Make (Impl.Ls_files)
    module Name_status = Vcs.Trait.Name_status.Make (Impl.Name_status)
    module Num_status = Vcs.Trait.Num_status.Make (Impl.Num_status)
    module Refs = Vcs.Trait.Refs.Make (Impl.Refs)
    module Show = Vcs.Trait.Show.Make (Impl.Show)
  end

  class c t =
    object
      inherit Class.Add.c t
      inherit Class.Branch.c t
      inherit Class.Commit.c t
      inherit Class.Config.c t
      inherit Class.Current_branch.c t
      inherit Class.Current_revision.c t
      inherit Class.File_system.c t
      inherit Class.Git.c t
      inherit Class.Init.c t
      inherit Class.Log.c t
      inherit Class.Ls_files.c t
      inherit Class.Name_status.c t
      inherit Class.Num_status.c t
      inherit Class.Refs.c t
      inherit Class.Show.c t
    end

  include Impl
end
