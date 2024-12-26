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
