(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type commit_method =
  repo_root:Repo_root.t -> commit_message:Commit_message.t -> (unit, Err.t) Result.t

module type S = sig
  type t

  val commit : t -> commit_method
end

class type t = object
  method commit : commit_method
end

module Make (X : S) = struct
  class c (t : X.t) =
    object
      method commit = X.commit t
    end
end
