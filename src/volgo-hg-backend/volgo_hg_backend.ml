(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Add = Add
module Commit = Commit
module Current_revision = Current_revision
module Init = Init
module Ls_files = Ls_files
module Runtime = Runtime
module Private = struct end

module Trait = struct
  class type t = object
    inherit Vcs.Trait.add
    inherit Vcs.Trait.commit
    inherit Vcs.Trait.current_revision
    inherit Vcs.Trait.file_system
    inherit Vcs.Trait.hg
    inherit Vcs.Trait.init
    inherit Vcs.Trait.ls_files
  end
end

module type S = sig
  type t

  class c : t -> Trait.t

  module Add : Vcs.Trait.Add.S with type t = t
  module Commit : Vcs.Trait.Commit.S with type t = t
  module Current_revision : Vcs.Trait.Current_revision.S with type t = t
  module File_system : Vcs.Trait.File_system.S with type t = t
  module Hg : Vcs.Trait.Hg.S with type t = t
  module Init : Vcs.Trait.Init.S with type t = t
  module Ls_files : Vcs.Trait.Ls_files.S with type t = t
end

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  module Impl = struct
    module Add = Add.Make (Runtime)
    module Commit = Commit.Make (Runtime)
    module Current_revision = Current_revision.Make (Runtime)
    module File_system = Runtime
    module Hg = Runtime
    module Init = Init.Make (Runtime)
    module Ls_files = Ls_files.Make (Runtime)
  end

  module Class = struct
    module Add = Vcs.Trait.Add.Make (Impl.Add)
    module Commit = Vcs.Trait.Commit.Make (Impl.Commit)
    module Current_revision = Vcs.Trait.Current_revision.Make (Impl.Current_revision)
    module File_system = Vcs.Trait.File_system.Make (Impl.File_system)
    module Hg = Vcs.Trait.Hg.Make (Impl.Hg)
    module Init = Vcs.Trait.Init.Make (Impl.Init)
    module Ls_files = Vcs.Trait.Ls_files.Make (Impl.Ls_files)
  end

  class c t =
    object
      inherit Class.Add.c t
      inherit Class.Commit.c t
      inherit Class.Current_revision.c t
      inherit Class.File_system.c t
      inherit Class.Hg.c t
      inherit Class.Init.c t
      inherit Class.Ls_files.c t
    end

  include Impl
end
