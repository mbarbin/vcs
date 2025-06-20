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

module Author = Author
module Branch_name = Branch_name
module Commit_message = Commit_message
module File_contents = File_contents
module Git = Git
module Graph = Graph
module Hg = Hg
module Log = Log
module Mock_rev_gen = Mock_rev_gen
module Mock_revs = Mock_revs
module Name_status = Name_status
module Non_raising = Non_raising
module Num_status = Num_status
module Num_lines_in_diff = Num_lines_in_diff
module Path_in_repo = Path_in_repo
module Platform = Platform
module Platform_repo = Platform_repo
module Ref_kind = Ref_kind
module Refs = Refs
module Remote_branch_name = Remote_branch_name
module Remote_name = Remote_name
module Repo_name = Repo_name
module Repo_root = Repo_root
module Result = Vcs_result
module Rresult = Vcs_rresult
module Rev = Rev
module Tag_name = Tag_name
module Trait = Trait
module User_email = User_email
module User_handle = User_handle
module User_name = User_name
include Vcs0

module Private = struct
  module Bit_vector = Bit_vector
  module Import = Import
  module Int_table = Int_table
  module Process_output = Process_output
  module Ref_kind_table = Ref_kind_table
  module Rev_table = Rev_table
  module Validated_string = Validated_string

  let try_with f =
    match f () with
    | ok -> Ok ok
    | exception exn -> Error (Err.of_exn exn)
  ;;
end
