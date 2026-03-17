(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type add_method = repo_root:Repo_root.t -> path:Path_in_repo.t -> (unit, Err.t) Result.t

module type S = sig
  type t

  val add : t -> add_method
end

class type t = object
  method add : add_method
end

module Make (X : S) = struct
  class c (t : X.t) =
    object
      method add = X.add t
    end
end
