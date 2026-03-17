(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

type ls_files_method =
  repo_root:Repo_root.t -> below:Path_in_repo.t -> (Path_in_repo.t list, Err.t) Result.t

module type S = sig
  type t

  val ls_files : t -> ls_files_method
end

class type t = object
  method ls_files : ls_files_method
end

module Make (X : S) : sig
  class c : X.t -> object
    inherit t
  end
end
