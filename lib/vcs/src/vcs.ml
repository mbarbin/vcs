(*******************************************************************************)
(*  Vcs - a versatile OCaml library for Git interaction                        *)
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

module Author = Author
module Branch_name = Branch_name
module Commit_message = Commit_message
module Err = Err
module Exn = Vcs_exn
module File_contents = File_contents
module For_test = For_test
module Git = Git
module Log = Log
module Mock_rev_gen = Mock_rev_gen
module Mock_revs = Mock_revs
module Name_status = Name_status
module Non_raising = Non_raising
module Num_status = Num_status
module Num_lines_in_diff = Num_lines_in_diff
module Or_error = Vcs_or_error
module Path_in_repo = Path_in_repo
module Platform = Platform
module Ref_kind = Ref_kind
module Refs = Refs
module Remote_branch_name = Remote_branch_name
module Remote_name = Remote_name
module Repo_name = Repo_name
module Repo_root = Repo_root
module Result = Vcs_result
module Rev = Rev
module Tag_name = Tag_name
module Trait = Trait
module Tree = Tree
module Url = Url
module User_email = User_email
module User_handle = User_handle
module User_name = User_name
include Exn0
include Vcs0

module Private = struct
  module Validated_string = Validated_string
end
