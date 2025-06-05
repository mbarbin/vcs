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

module Add = Add
module Commit = Commit
module Init = Init
module Ls_files = Ls_files
module Rev_parse = Rev_parse
module Runtime = Runtime
module Private = struct end

module Trait = struct
  class type t = object
    inherit Vcs.Trait.add
    inherit Vcs.Trait.commit
    inherit Vcs.Trait.file_system
    inherit Vcs.Trait.hg
    inherit Vcs.Trait.init
    inherit Vcs.Trait.ls_files
    inherit Vcs.Trait.rev_parse
  end
end

module type S = sig
  type t

  class c : t -> Trait.t

  module Add : Vcs.Trait.Add.S with type t = t
  module Commit : Vcs.Trait.Commit.S with type t = t
  module File_system : Vcs.Trait.File_system.S with type t = t
  module Hg : Vcs.Trait.Hg.S with type t = t
  module Init : Vcs.Trait.Init.S with type t = t
  module Ls_files : Vcs.Trait.Ls_files.S with type t = t
  module Rev_parse : Vcs.Trait.Rev_parse.S with type t = t
end

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  module Impl = struct
    module Add = Add.Make (Runtime)
    module Commit = Commit.Make (Runtime)
    module File_system = Runtime
    module Hg = Runtime
    module Init = Init.Make (Runtime)
    module Ls_files = Ls_files.Make (Runtime)
    module Rev_parse = Rev_parse.Make (Runtime)
  end

  module Class = struct
    module Add = Vcs.Trait.Add.Make (Impl.Add)
    module Commit = Vcs.Trait.Commit.Make (Impl.Commit)
    module File_system = Vcs.Trait.File_system.Make (Impl.File_system)
    module Hg = Vcs.Trait.Hg.Make (Impl.Hg)
    module Init = Vcs.Trait.Init.Make (Impl.Init)
    module Ls_files = Vcs.Trait.Ls_files.Make (Impl.Ls_files)
    module Rev_parse = Vcs.Trait.Rev_parse.Make (Impl.Rev_parse)
  end

  class c t =
    object
      inherit Class.Add.c t
      inherit Class.Commit.c t
      inherit Class.File_system.c t
      inherit Class.Hg.c t
      inherit Class.Init.c t
      inherit Class.Ls_files.c t
      inherit Class.Rev_parse.c t
    end

  include Impl
end
