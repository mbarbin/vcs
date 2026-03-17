(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

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

module Make (X : S) : sig
  class c : X.t -> object
    inherit t
  end
end
