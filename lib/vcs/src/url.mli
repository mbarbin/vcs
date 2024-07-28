(*_******************************************************************************)
(*_  Vcs - a Versatile OCaml Library for Git Interaction                        *)
(*_  Copyright (C) 2024 Mathieu Barbin <mathieu.barbin@gmail.com>               *)
(*_                                                                             *)
(*_  This file is part of Vcs.                                                  *)
(*_                                                                             *)
(*_  Vcs is free software; you can redistribute it and/or modify it under       *)
(*_  the terms of the GNU Lesser General Public License as published by the     *)
(*_  Free Software Foundation either version 3 of the License, or any later     *)
(*_  version, with the LGPL-3.0 Linking Exception.                              *)
(*_                                                                             *)
(*_  Vcs is distributed in the hope that it will be useful, but WITHOUT ANY     *)
(*_  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*_  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*_  the file `NOTICE.md` at the root of this repository for more details.      *)
(*_                                                                             *)
(*_  You should have received a copy of the GNU Lesser General Public License   *)
(*_  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*_  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*_******************************************************************************)

(** A url to access a repository on a supported platform.

    Some examples:

    {[
      [ "https://github.com/ahrefs/atd.git"; "git@github.com:mbarbin/ocaml-grpc.git" ]
    ]} *)

module Protocol : sig
  type t =
    | Ssh
    | Https
  [@@deriving compare, equal, enumerate, hash, sexp_of]
end

type t =
  { platform : Platform.t
  ; protocol : Protocol.t
  ; user_handle : User_handle.t
  ; repo_name : Repo_name.t
  }
[@@deriving compare, equal, hash, sexp_of]

(** Create a complete string suitable for use with git commands, such as remote
    add, clone, etc. *)
val to_string : t -> string

(** Parse a string into a url. *)
val of_string : string -> t Or_error.t
