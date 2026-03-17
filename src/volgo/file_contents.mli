(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Representing the raw contents of files on disk. *)

(** This is a simple wrapper for the type string, used to increase type safety. *)
type t = private string

include Container_key.S with type t := t

(** [create file_contents] returns a [t] representing the given file contents. *)
val create : string -> t

(** [to_string s] is a convenient wrapper for [(s :> string)] for use with [map]
    functions. *)
val to_string : t -> string
