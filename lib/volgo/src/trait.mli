(*_******************************************************************************)
(*_  Volgo - a Versatile OCaml Library for Git Operations                       *)
(*_  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
(*_                                                                             *)
(*_  This file is part of Volgo.                                                *)
(*_                                                                             *)
(*_  Volgo is free software; you can redistribute it and/or modify it under     *)
(*_  the terms of the GNU Lesser General Public License as published by the     *)
(*_  Free Software Foundation either version 3 of the License, or any later     *)
(*_  version, with the LGPL-3.0 Linking Exception.                              *)
(*_                                                                             *)
(*_  Volgo is distributed in the hope that it will be useful, but WITHOUT ANY   *)
(*_  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*_  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*_  the file `NOTICE.md` at the root of this repository for more details.      *)
(*_                                                                             *)
(*_  You should have received a copy of the GNU Lesser General Public License   *)
(*_  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*_  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*_******************************************************************************)

(** The traits that [Vcs] depends on to implement its functionality.

    [Vcs] is parametrized by a list of specific interfaces and classes that
    constitute the low level operations needed by [Vcs]. We call them [traits].

    The intended usage for a library that requires [Vcs] functionality is to
    specify via the type of the [vcs] value, the exact list of traits required.
    Doing this in this way, allows for flexibility, as any backend supplying
    that list of traits or more will be compatible as a backend to be supplied
    to your code.

    For example, consider a function that needs to list all the files under
    version control, and show their contents at some revision. Such
    functionality will require:

    {[
      val my_vcs_function
        : vcs : < Vcs.Trait.ls_files ; Vcs.Trait.show ; .. > Vcs.t
        -> ..
        -> ..
    ]} *)

class type add = Trait_add.t

module Add : sig
  module type S = Trait_add.S

  module Make (X : S) : sig
    class c : X.t -> object
      inherit add
    end
  end
end

class type branch = Trait_branch.t

module Branch : sig
  module type S = Trait_branch.S

  module Make (X : S) : sig
    class c : X.t -> object
      inherit branch
    end
  end
end

class type commit = Trait_commit.t

module Commit : sig
  module type S = Trait_commit.S

  module Make (X : S) : sig
    class c : X.t -> object
      inherit commit
    end
  end
end

class type config = Trait_config.t

module Config : sig
  module type S = Trait_config.S

  module Make (X : S) : sig
    class c : X.t -> object
      inherit config
    end
  end
end

class type current_branch = Trait_current_branch.t

module Current_branch : sig
  module type S = Trait_current_branch.S

  module Make (X : S) : sig
    class c : X.t -> object
      inherit current_branch
    end
  end
end

class type current_revision = Trait_current_revision.t

module Current_revision : sig
  module type S = Trait_current_revision.S

  module Make (X : S) : sig
    class c : X.t -> object
      inherit current_revision
    end
  end
end

class type file_system = Trait_file_system.t

module File_system : sig
  module type S = Trait_file_system.S

  module Make (X : S) : sig
    class c : X.t -> object
      inherit file_system
    end
  end
end

class type git = Trait_git.t

module Git : sig
  module type S = Trait_git.S

  module Make (X : S) : sig
    class c : X.t -> object
      inherit git
    end
  end
end

class type hg = Trait_hg.t

module Hg : sig
  module type S = Trait_hg.S

  module Make (X : S) : sig
    class c : X.t -> object
      inherit hg
    end
  end
end

class type init = Trait_init.t

module Init : sig
  module type S = Trait_init.S

  module Make (X : S) : sig
    class c : X.t -> object
      inherit init
    end
  end
end

class type log = Trait_log.t

module Log : sig
  module type S = Trait_log.S

  module Make (X : S) : sig
    class c : X.t -> object
      inherit log
    end
  end
end

class type ls_files = Trait_ls_files.t

module Ls_files : sig
  module type S = Trait_ls_files.S

  module Make (X : S) : sig
    class c : X.t -> object
      inherit ls_files
    end
  end
end

class type name_status = Trait_name_status.t

module Name_status : sig
  module type S = Trait_name_status.S

  module Make (X : S) : sig
    class c : X.t -> object
      inherit name_status
    end
  end
end

class type num_status = Trait_num_status.t

module Num_status : sig
  module type S = Trait_num_status.S

  module Make (X : S) : sig
    class c : X.t -> object
      inherit num_status
    end
  end
end

class type refs = Trait_refs.t

module Refs : sig
  module type S = Trait_refs.S

  module Make (X : S) : sig
    class c : X.t -> object
      inherit refs
    end
  end
end

class type show = Trait_show.t

module Show : sig
  module type S = Trait_show.S

  module Make (X : S) : sig
    class c : X.t -> object
      inherit show
    end
  end
end

(** The union of all traits defined in Vcs. *)
class type t = object
  inherit add
  inherit branch
  inherit commit
  inherit config
  inherit current_branch
  inherit current_revision
  inherit file_system
  inherit git
  inherit hg
  inherit init
  inherit log
  inherit ls_files
  inherit name_status
  inherit num_status
  inherit refs
  inherit show
end

(** This is a special class constructor that creates an object that satisfies
    the interface defined by the class type [t], but where each of the actual
    method implementation is a function that returns an error indicating that
    the method is unimplemented.

    This may be useful when you wish to define an object that fails at runtime
    rather than at compile time, as a base object to extend, such as in:

    {[
      let my_vcs =
        object
          inherit Vcs.Trait.unimplemented

          method! ...

          inherit! ...
        end
    ]}

    We do this for example in the implementation of the cli [volgo-vcs] to
    define the [vcs] used for Mercurial repositories.

    Note however that in most cases, you'd probably be better off dealing with
    traits in a static way, by specifying and requiring [vcs] values that
    implement the exact set of traits that you need. *)
class unimplemented : t
