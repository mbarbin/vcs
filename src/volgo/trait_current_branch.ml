(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type current_branch_method =
  repo_root:Repo_root.t -> (Branch_name.t option, Err.t) Result.t

module type S = sig
  type t

  val current_branch : t -> current_branch_method
end

class type t = object
  method current_branch : current_branch_method
end

module Make (X : S) = struct
  class c (t : X.t) =
    object
      method current_branch = X.current_branch t
    end
end
