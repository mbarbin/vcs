(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type rename_current_branch_method =
  repo_root:Repo_root.t -> to_:Branch_name.t -> (unit, Err.t) Result.t

module type S = sig
  type t

  val rename_current_branch : t -> rename_current_branch_method
end

class type t = object
  method rename_current_branch : rename_current_branch_method
end

module Make (X : S) = struct
  class c (t : X.t) =
    object
      method rename_current_branch = X.rename_current_branch t
    end
end
