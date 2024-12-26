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

(** The traits that [Vcs] depends on to implement its functionality.

    Vcs uses the {{:https://github.com/mbarbin/provider} provider} library in
    order not to commit to a specific implementation for the low level
    interaction with git. This works by defining a set of traits that constitute
    the low level operations needed by [Vcs].

    Casual users of [Vcs] are not expected to use this module directly. Rather
    this is used by implementers of providers for the [Vcs] library. *)

module Add = Trait_add
module Branch = Trait_branch
module Commit = Trait_commit
module Config = Trait_config
module File_system = Trait_file_system
module Git = Trait_git
module Init = Trait_init
module Log = Trait_log
module Ls_files = Trait_ls_files
module Name_status = Trait_name_status
module Num_status = Trait_num_status
module Refs = Trait_refs
module Rev_parse = Trait_rev_parse
module Show = Trait_show

(** The union of all traits defined in Vcs. *)
class type t = object
  inherit Add.t
  inherit Branch.t
  inherit Commit.t
  inherit Config.t
  inherit File_system.t
  inherit Git.t
  inherit Init.t
  inherit Log.t
  inherit Ls_files.t
  inherit Name_status.t
  inherit Num_status.t
  inherit Refs.t
  inherit Rev_parse.t
  inherit Show.t
end
