(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
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

type set_user_name_method =
  repo_root:Repo_root.t -> user_name:User_name.t -> (unit, Err.t) Result.t

type set_user_email_method =
  repo_root:Repo_root.t -> user_email:User_email.t -> (unit, Err.t) Result.t

module type S = sig
  type t

  val set_user_name : t -> set_user_name_method
  val set_user_email : t -> set_user_email_method
end

class type t = object
  method set_user_name : set_user_name_method
  method set_user_email : set_user_email_method
end

module Make (X : S) = struct
  class c (t : X.t) =
    object
      method set_user_name = X.set_user_name t
      method set_user_email = X.set_user_email t
    end
end
