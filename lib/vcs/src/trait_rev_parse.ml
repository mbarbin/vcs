(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024 Mathieu Barbin <mathieu.barbin@gmail.com>               *)
(*                                                                             *)
(*  This file is part of Vcs.                                                  *)
(*                                                                             *)
(*  Vcs is free software; you can redistribute it and/or modify it under       *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Vcs is distributed in the hope that it will be useful, but WITHOUT ANY     *)
(*  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*  the file `NOTICE.md` at the root of this repository for more details.      *)
(*                                                                             *)
(*  You should have received a copy of the GNU Lesser General Public License   *)
(*  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*******************************************************************************)

type current_branch_method = repo_root:Repo_root.t -> (Branch_name.t, Err.t) Result.t
type current_revision_method = repo_root:Repo_root.t -> (Rev.t, Err.t) Result.t

module type S = sig
  type t

  val current_branch : t -> current_branch_method
  val current_revision : t -> current_revision_method
end

class type t = object
  method current_branch : current_branch_method
  method current_revision : current_revision_method
end

module Make (X : S) = struct
  class c (t : X.t) =
    object
      method current_branch = X.current_branch t
      method current_revision = X.current_revision t
    end
end
