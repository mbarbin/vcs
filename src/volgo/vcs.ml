(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

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

module File_shown_at_rev = struct
  type t =
    [ `Present of File_contents.t
    | `Absent
    ]

  let to_dyn : t -> Dyn.t = function
    | `Absent -> Dyn.Variant ("Absent", [])
    | `Present file_contents ->
      Dyn.Variant ("Present", [ File_contents.to_dyn file_contents ])
  ;;

  let sexp_of_t t = Dyn.to_sexp (to_dyn t)
end
