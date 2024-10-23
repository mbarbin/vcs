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

(** An extension of the Vcs library for use with Base.

    [Vcs_base] is a library that extends the [Vcs] library with additional
    modules and functionalities, aimed to improve the compatibility of [Vcs] for
    programs using [Base].

    For example, it adds [Comparable.S] to all container keys modules so that
    they can be used with Base-style containers:

    {[
      let create_path_in_repo_table () = Hashtbl.create (module Vcs.Path_in_repo)
    ]}

    There's also a new module [Vcs.Or_error] which allows using [Vcs] with the
    [Or_error] monad.

    The library is designed to be used as a drop-in replacement for [Vcs]. For
    this, it includes a single module named [Vcs] which must be setup to shadow
    the regular [Vcs] module.

    You may do so by defining the following module alias in a place that's
    available to your scope:

    {[
      module Vcs = Vcs_base.Vcs
    ]}

    Another way to achieve this is to open [Vcs_base] via dune flags. When doing
    that, all the files in your library will use [Vcs_base.Vcs] consistently.

    {v
      (library
        (name my_library)
        (flags (:standard -open Vcs_base))
        (libraries vcs-base))
    v}

    This pattern is Vcs's authors favorite way of using [Vcs_base] and is the
    way we're setting up [Vcs_base] in the examples of the Vcs repository. *)

module Vcs : sig
  (** {1 Extended Vcs API} *)

  module Author = Author
  module Branch_name = Branch_name
  module Commit_message = Commit_message
  module Err = Err
  module File_contents = File_contents
  module Git = Git
  module Graph = Graph
  module Name_status = Name_status
  module Num_lines_in_diff = Num_lines_in_diff
  module Path_in_repo = Path_in_repo
  module Platform = Platform
  module Ref_kind = Ref_kind
  module Refs = Refs
  module Remote_branch_name = Remote_branch_name
  module Remote_name = Remote_name
  module Repo_name = Repo_name
  module Repo_root = Repo_root
  module Rev = Rev
  module Tag_name = Tag_name
  module Url = Url
  module User_email = User_email
  module User_handle = User_handle
  module User_name = User_name

  include
    module type of Vcs
    with module Author := Vcs.Author
     and module Branch_name := Vcs.Branch_name
     and module Commit_message := Vcs.Commit_message
     and module Err := Vcs.Err
     and module File_contents := Vcs.File_contents
     and module Git := Vcs.Git
     and module Graph := Vcs.Graph
     and module Name_status := Vcs.Name_status
     and module Num_lines_in_diff := Vcs.Num_lines_in_diff
     and module Path_in_repo := Vcs.Path_in_repo
     and module Platform := Vcs.Platform
     and module Ref_kind := Vcs.Ref_kind
     and module Refs := Vcs.Refs
     and module Remote_branch_name := Vcs.Remote_branch_name
     and module Remote_name := Vcs.Remote_name
     and module Repo_name := Vcs.Repo_name
     and module Repo_root := Vcs.Repo_root
     and module Rev := Vcs.Rev
     and module Tag_name := Vcs.Tag_name
     and module Url := Vcs.Url
     and module User_email := Vcs.User_email
     and module User_handle := Vcs.User_handle
     and module User_name := Vcs.User_name

  (** {1 Additional modules} *)

  module Or_error = Vcs_or_error
end
