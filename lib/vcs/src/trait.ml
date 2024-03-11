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

type add = [ `Add of add_ty ]
and add_ty

module Add = struct
  module type S = Trait_add.S
end

type branch = [ `Branch of branch_ty ]
and branch_ty

module Branch = struct
  module type S = Trait_branch.S
end

type commit = [ `Commit of commit_ty ]
and commit_ty

module Commit = struct
  module type S = Trait_commit.S
end

type config = [ `Config of config_ty ]
and config_ty

module Config = struct
  module type S = Trait_config.S
end

type file_system = [ `File_system of file_system_ty ]
and file_system_ty

module File_system = struct
  module type S = Trait_file_system.S
end

type git = [ `Git of git_ty ]
and git_ty

module Git = struct
  module type S = Trait_git.S
end

type init = [ `Init of init_ty ]
and init_ty

module Init = struct
  module type S = Trait_init.S
end

type log = [ `Log of log_ty ]
and log_ty

module Log = struct
  module type S = Trait_log.S
end

type ls_files = [ `Ls_files of ls_files_ty ]
and ls_files_ty

module Ls_files = struct
  module type S = Trait_ls_files.S
end

type name_status = [ `Name_status of name_status_ty ]
and name_status_ty

module Name_status = struct
  module type S = Trait_name_status.S
end

type num_status = [ `Num_status of num_status_ty ]
and num_status_ty

module Num_status = struct
  module type S = Trait_num_status.S
end

type refs = [ `Refs of refs_ty ]
and refs_ty

module Refs = struct
  module type S = Trait_refs.S
end

type rev_parse = [ `Rev_parse of rev_parse_ty ]
and rev_parse_ty

module Rev_parse = struct
  module type S = Trait_rev_parse.S
end

type show = [ `Show of show_ty ]
and show_ty

module Show = struct
  module type S = Trait_show.S
end

type (_, _, _) Provider.Trait.t +=
  | Add : ('t, (module Add.S with type t = 't), [> add ]) Provider.Trait.t
  | Branch : ('t, (module Branch.S with type t = 't), [> branch ]) Provider.Trait.t
  | Commit : ('t, (module Commit.S with type t = 't), [> commit ]) Provider.Trait.t
  | Config : ('t, (module Config.S with type t = 't), [> config ]) Provider.Trait.t
  | File_system :
      ('t, (module File_system.S with type t = 't), [> file_system ]) Provider.Trait.t
  | Git : ('t, (module Git.S with type t = 't), [> git ]) Provider.Trait.t
  | Init : ('t, (module Init.S with type t = 't), [> init ]) Provider.Trait.t
  | Log : ('t, (module Log.S with type t = 't), [> log ]) Provider.Trait.t
  | Ls_files : ('t, (module Ls_files.S with type t = 't), [> ls_files ]) Provider.Trait.t
  | Name_status :
      ('t, (module Name_status.S with type t = 't), [> name_status ]) Provider.Trait.t
  | Num_status :
      ('t, (module Num_status.S with type t = 't), [> num_status ]) Provider.Trait.t
  | Refs : ('t, (module Refs.S with type t = 't), [> refs ]) Provider.Trait.t
  | Rev_parse :
      ('t, (module Rev_parse.S with type t = 't), [> rev_parse ]) Provider.Trait.t
  | Show : ('t, (module Show.S with type t = 't), [> show ]) Provider.Trait.t

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
