(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type name_status_method =
  repo_root:Repo_root.t
  -> changed:Name_status.Changed.t
  -> (Name_status.t, Err.t) Result.t

module type S = sig
  type t

  val name_status : t -> name_status_method
end

class type t = object
  method name_status : name_status_method
end

module Make (X : S) = struct
  class c (t : X.t) =
    object
      method name_status = X.name_status t
    end
end
