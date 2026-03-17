(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** A [platform] in vcs' terminology is an online software development service
    where users host repositories, such as ["GitHub"].

    This type is used to implement utilities for interacting with various
    platforms, for example to clone repositories.

    The list of supported platforms may grow over time. *)

(** @canonical Volgo.Vcs.Platform.t *)
type t =
  | Bitbucket
  | Codeberg
  | GitHub
  | GitLab
  | Sourcehut

include Container_key.S with type t := t

val all : t list

(** A string representing the platform, using the styled capitalization of the
    variant constructor. For example, ["GitHub"] is typically spelled with an
    uppercase 'H'. This is suitable for inclusion into error messages, user
    facing logs, etc. *)
val to_string : t -> string
