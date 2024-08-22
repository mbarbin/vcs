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

  let handler () : (t, [> Trait.t ]) Provider.Handler.t =
    Provider.Handler.make
      [ Provider.Trait.implement Vcs.Trait.Add ~impl:(module Impl.Add)
      ; Provider.Trait.implement Vcs.Trait.Branch ~impl:(module Impl.Branch)
      ; Provider.Trait.implement Vcs.Trait.Commit ~impl:(module Impl.Commit)
      ; Provider.Trait.implement Vcs.Trait.Config ~impl:(module Impl.Config)
      ; Provider.Trait.implement Vcs.Trait.File_system ~impl:(module Impl.File_system)
      ; Provider.Trait.implement Vcs.Trait.Git ~impl:(module Impl.Git)
      ; Provider.Trait.implement Vcs.Trait.Init ~impl:(module Impl.Init)
      ; Provider.Trait.implement Vcs.Trait.Log ~impl:(module Impl.Log)
      ; Provider.Trait.implement Vcs.Trait.Ls_files ~impl:(module Impl.Ls_files)
      ; Provider.Trait.implement Vcs.Trait.Name_status ~impl:(module Impl.Name_status)
      ; Provider.Trait.implement Vcs.Trait.Num_status ~impl:(module Impl.Num_status)
      ; Provider.Trait.implement Vcs.Trait.Refs ~impl:(module Impl.Refs)
      ; Provider.Trait.implement Vcs.Trait.Rev_parse ~impl:(module Impl.Rev_parse)
      ; Provider.Trait.implement Vcs.Trait.Show ~impl:(module Impl.Show)
      ]
  ;;

  include Impl
end
