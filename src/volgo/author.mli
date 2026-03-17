(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Author information as commonly used in Git.

    Usually, this is the information of the user who committed a change. The author
    information contains the user name and email.

    For example: [Author.v "John Doe <john.doe@mail.com>"]. *)

type t (** @canonical Vcs.Author.t *)

include Container_key.S with type t := t
include Validated_string.S with type t := t

val of_user_config : user_name:User_name.t -> user_email:User_email.t -> t
