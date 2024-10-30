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

type add = [ `Add of add_ty ]
and add_ty

module Add : sig
  module type S = Trait_add.S

  val t : ('t, (module S with type t = 't), [> add ]) Provider.Trait.t
end

type branch = [ `Branch of branch_ty ]
and branch_ty

module Branch : sig
  module type S = Trait_branch.S

  val t : ('t, (module S with type t = 't), [> branch ]) Provider.Trait.t
end

type commit = [ `Commit of commit_ty ]
and commit_ty

module Commit : sig
  module type S = Trait_commit.S

  val t : ('t, (module S with type t = 't), [> commit ]) Provider.Trait.t
end

type config = [ `Config of config_ty ]
and config_ty

module Config : sig
  module type S = Trait_config.S

  val t : ('t, (module S with type t = 't), [> config ]) Provider.Trait.t
end

type file_system = [ `File_system of file_system_ty ]
and file_system_ty

module File_system : sig
  module type S = Trait_file_system.S

  val t : ('t, (module S with type t = 't), [> file_system ]) Provider.Trait.t
end

type git = [ `Git of git_ty ]
and git_ty

module Git : sig
  module type S = Trait_git.S

  val t : ('t, (module S with type t = 't), [> git ]) Provider.Trait.t
end

type init = [ `Init of init_ty ]
and init_ty

module Init : sig
  module type S = Trait_init.S

  val t : ('t, (module S with type t = 't), [> init ]) Provider.Trait.t
end

type log = [ `Log of log_ty ]
and log_ty

module Log : sig
  module type S = Trait_log.S

  val t : ('t, (module S with type t = 't), [> log ]) Provider.Trait.t
end

type ls_files = [ `Ls_files of ls_files_ty ]
and ls_files_ty

module Ls_files : sig
  module type S = Trait_ls_files.S

  val t : ('t, (module S with type t = 't), [> ls_files ]) Provider.Trait.t
end

type name_status = [ `Name_status of name_status_ty ]
and name_status_ty

module Name_status : sig
  module type S = Trait_name_status.S

  val t : ('t, (module S with type t = 't), [> name_status ]) Provider.Trait.t
end

type num_status = [ `Num_status of num_status_ty ]
and num_status_ty

module Num_status : sig
  module type S = Trait_num_status.S

  val t : ('t, (module S with type t = 't), [> num_status ]) Provider.Trait.t
end

type refs = [ `Refs of refs_ty ]
and refs_ty

module Refs : sig
  module type S = Trait_refs.S

  val t : ('t, (module S with type t = 't), [> refs ]) Provider.Trait.t
end

type rev_parse = [ `Rev_parse of rev_parse_ty ]
and rev_parse_ty

module Rev_parse : sig
  module type S = Trait_rev_parse.S

  val t : ('t, (module S with type t = 't), [> rev_parse ]) Provider.Trait.t
end

type show = [ `Show of show_ty ]
and show_ty

module Show : sig
  module type S = Trait_show.S

  val t : ('t, (module S with type t = 't), [> show ]) Provider.Trait.t
end

(** The union of all traits defined in Vcs. *)
type t =
  [ add
  | branch
  | commit
  | config
  | file_system
  | git
  | init
  | log
  | ls_files
  | name_status
  | num_status
  | refs
  | rev_parse
  | show
  ]
