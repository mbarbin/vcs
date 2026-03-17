(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type show_file_at_rev_method =
  repo_root:Repo_root.t
  -> rev:Rev.t
  -> path:Path_in_repo.t
  -> ([ `Present of File_contents.t | `Absent ], Err.t) Result.t

module type S = sig
  type t

  val show_file_at_rev : t -> show_file_at_rev_method
end

class type t = object
  method show_file_at_rev : show_file_at_rev_method
end

module Make (X : S) = struct
  class c (t : X.t) =
    object
      method show_file_at_rev = X.show_file_at_rev t
    end
end
