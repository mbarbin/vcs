(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
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

class type add = Add.t
class type branch = Branch.t
class type commit = Commit.t
class type config = Config.t
class type file_system = File_system.t
class type git = Git.t
class type init = Init.t
class type log = Log.t
class type ls_files = Ls_files.t
class type name_status = Name_status.t
class type num_status = Num_status.t
class type refs = Refs.t
class type rev_parse = Rev_parse.t
class type show = Show.t

class type t = object
  inherit add
  inherit branch
  inherit commit
  inherit config
  inherit file_system
  inherit git
  inherit init
  inherit log
  inherit ls_files
  inherit name_status
  inherit num_status
  inherit refs
  inherit rev_parse
  inherit show
end
