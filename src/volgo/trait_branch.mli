(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

type rename_current_branch_method =
  repo_root:Repo_root.t -> to_:Branch_name.t -> (unit, Err.t) Result.t

module type S = sig
  type t

  (** This translates to [git branch --move NAME], which is used to enforce the
      name of a default branch during tests. *)
  val rename_current_branch : t -> rename_current_branch_method
end

class type t = object
  method rename_current_branch : rename_current_branch_method
end

module Make (X : S) : sig
  class c : X.t -> object
    inherit t
  end
end
