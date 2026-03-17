(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

type init_method = path:Absolute_path.t -> (Repo_root.t, Err.t) Result.t

module type S = sig
  type t

  (** Initialize a git repository at the given path. This errors out if a
      repository is already initialized there. *)
  val init : t -> init_method
end

class type t = object
  method init : init_method
end

module Make (X : S) : sig
  class c : X.t -> object
    inherit t
  end
end
