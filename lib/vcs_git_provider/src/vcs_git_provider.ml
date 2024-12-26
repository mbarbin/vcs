(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024 Mathieu Barbin <mathieu.barbin@gmail.com>               *)
(*                                                                             *)
(*  This file is part of Vcs.                                                  *)
(*                                                                             *)
(*  Vcs is free software; you can redistribute it and/or modify it under       *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Vcs is distributed in the hope that it will be useful, but WITHOUT ANY     *)
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
module Init = Init
module Log = Log
module Ls_files = Ls_files
module Name_status = Name_status
module Num_status = Num_status
module Refs = Refs
module Rev_parse = Rev_parse
module Runtime = Runtime
module Show = Show

module Private = struct
  module Munged_path = Munged_path
end

module Trait = struct
  class type t = object
    inherit Vcs.Trait.Add.t
    inherit Vcs.Trait.Branch.t
    inherit Vcs.Trait.Commit.t
    inherit Vcs.Trait.Config.t
    inherit Vcs.Trait.File_system.t
    inherit Vcs.Trait.Git.t
    inherit Vcs.Trait.Init.t
    inherit Vcs.Trait.Log.t
    inherit Vcs.Trait.Ls_files.t
    inherit Vcs.Trait.Name_status.t
    inherit Vcs.Trait.Num_status.t
    inherit Vcs.Trait.Refs.t
    inherit Vcs.Trait.Rev_parse.t
    inherit Vcs.Trait.Show.t
  end
end

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  module Impl = struct
    module Add = Add.Make (Runtime)
    module Branch = Branch.Make (Runtime)
    module Commit = Commit.Make (Runtime)
    module Config = Config.Make (Runtime)
    module File_system = Runtime
    module Git = Runtime
    module Init = Init.Make (Runtime)
    module Log = Log.Make (Runtime)
    module Ls_files = Ls_files.Make (Runtime)
    module Name_status = Name_status.Make (Runtime)
    module Num_status = Num_status.Make (Runtime)
    module Refs = Refs.Make (Runtime)
    module Rev_parse = Rev_parse.Make (Runtime)
    module Show = Show.Make (Runtime)
  end

  module Class = struct
    module Add = Vcs.Trait.Add.Make (Impl.Add)
    module Branch = Vcs.Trait.Branch.Make (Impl.Branch)
    module Commit = Vcs.Trait.Commit.Make (Impl.Commit)
    module Config = Vcs.Trait.Config.Make (Impl.Config)
    module File_system = Vcs.Trait.File_system.Make (Impl.File_system)
    module Git = Vcs.Trait.Git.Make (Impl.Git)
    module Init = Vcs.Trait.Init.Make (Impl.Init)
    module Log = Vcs.Trait.Log.Make (Impl.Log)
    module Ls_files = Vcs.Trait.Ls_files.Make (Impl.Ls_files)
    module Name_status = Vcs.Trait.Name_status.Make (Impl.Name_status)
    module Num_status = Vcs.Trait.Num_status.Make (Impl.Num_status)
    module Refs = Vcs.Trait.Refs.Make (Impl.Refs)
    module Rev_parse = Vcs.Trait.Rev_parse.Make (Impl.Rev_parse)
    module Show = Vcs.Trait.Show.Make (Impl.Show)
  end

  class c t =
    object
      inherit Class.Add.c t
      inherit Class.Branch.c t
      inherit Class.Commit.c t
      inherit Class.Config.c t
      inherit Class.File_system.c t
      inherit Class.Git.c t
      inherit Class.Init.c t
      inherit Class.Log.c t
      inherit Class.Ls_files.c t
      inherit Class.Name_status.c t
      inherit Class.Num_status.c t
      inherit Class.Refs.c t
      inherit Class.Rev_parse.c t
      inherit Class.Show.c t
    end

  include Impl
end
