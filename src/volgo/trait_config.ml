(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

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
