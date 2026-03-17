(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type init_method = path:Absolute_path.t -> (Repo_root.t, Err.t) Result.t

module type S = sig
  type t

  val init : t -> init_method
end

class type t = object
  method init : init_method
end

module Make (X : S) = struct
  class c (t : X.t) =
    object
      method init = X.init t
    end
end
