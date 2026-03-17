(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Defining the interface of a compatible runtime.

    The other modules defined by [Volgo_git_backend] are all functors that are
    parametrized by this interface. *)

module type S = sig
  type t

  (** {1 I/O} *)

  include Vcs.Trait.File_system.S with type t := t

  (** {1 Running the git command line} *)

  include Vcs.Trait.Hg.S with type t := t
end
