(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

type get_log_lines_method = repo_root:Repo_root.t -> (Log.t, Err.t) Result.t

module type S = sig
  type t

  val get_log_lines : t -> get_log_lines_method
end

class type t = object
  method get_log_lines : get_log_lines_method
end

module Make (X : S) : sig
  class c : X.t -> object
    inherit t
  end
end
