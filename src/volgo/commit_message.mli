(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** A commit message.

    This is meant for small commit messages when creating commits. It currently
    sets some arbitrary limits on the length of the message, and mustn't be
    empty. *)

type t

include Container_key.S with type t := t
include Validated_string.S with type t := t
