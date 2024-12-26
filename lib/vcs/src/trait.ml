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

type add = [ `Add of add_ty ]
and add_ty

module Add = struct
  include Trait_add

  include Provider.Trait.Create (struct
      type 'a module_type = (module S with type t = 'a)
    end)
end

type branch = [ `Branch of branch_ty ]
and branch_ty

module Branch = struct
  include Trait_branch

  include Provider.Trait.Create (struct
      type 'a module_type = (module S with type t = 'a)
    end)
end

type commit = [ `Commit of commit_ty ]
and commit_ty

module Commit = struct
  include Trait_commit

  include Provider.Trait.Create (struct
      type 'a module_type = (module S with type t = 'a)
    end)
end

type config = [ `Config of config_ty ]
and config_ty

module Config = struct
  include Trait_config

  include Provider.Trait.Create (struct
      type 'a module_type = (module S with type t = 'a)
    end)
end

type file_system = [ `File_system of file_system_ty ]
and file_system_ty

module File_system = struct
  include Trait_file_system

  include Provider.Trait.Create (struct
      type 'a module_type = (module S with type t = 'a)
    end)
end

type git = [ `Git of git_ty ]
and git_ty

module Git = struct
  include Trait_git

  include Provider.Trait.Create (struct
      type 'a module_type = (module S with type t = 'a)
    end)
end

type init = [ `Init of init_ty ]
and init_ty

module Init = struct
  include Trait_init

  include Provider.Trait.Create (struct
      type 'a module_type = (module S with type t = 'a)
    end)
end

type log = [ `Log of log_ty ]
and log_ty

module Log = struct
  include Trait_log

  include Provider.Trait.Create (struct
      type 'a module_type = (module S with type t = 'a)
    end)
end

type ls_files = [ `Ls_files of ls_files_ty ]
and ls_files_ty

module Ls_files = struct
  include Trait_ls_files

  include Provider.Trait.Create (struct
      type 'a module_type = (module S with type t = 'a)
    end)
end

type name_status = [ `Name_status of name_status_ty ]
and name_status_ty

module Name_status = struct
  include Trait_name_status

  include Provider.Trait.Create (struct
      type 'a module_type = (module S with type t = 'a)
    end)
end

type num_status = [ `Num_status of num_status_ty ]
and num_status_ty

module Num_status = struct
  include Trait_num_status

  include Provider.Trait.Create (struct
      type 'a module_type = (module S with type t = 'a)
    end)
end

type refs = [ `Refs of refs_ty ]
and refs_ty

module Refs = struct
  include Trait_refs

  include Provider.Trait.Create (struct
      type 'a module_type = (module S with type t = 'a)
    end)
end

type rev_parse = [ `Rev_parse of rev_parse_ty ]
and rev_parse_ty

module Rev_parse = struct
  include Trait_rev_parse

  include Provider.Trait.Create (struct
      type 'a module_type = (module S with type t = 'a)
    end)
end

type show = [ `Show of show_ty ]
and show_ty

module Show = struct
  include Trait_show

  include Provider.Trait.Create (struct
      type 'a module_type = (module S with type t = 'a)
    end)
end

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
