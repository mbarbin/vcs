(*_******************************************************************************)
(*_  Vcs - a Versatile OCaml Library for Git Operations                         *)
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

(** Util to parse paths that are written using a munged form by git.

    Example of such paths:

    1. A simple path:
    {[
      "a/simple/path"
    ]}

    2. A pair of paths, with an arrow separator
    {[
      "a/simple/path => another/path"
    ]}

    3. (The more involved case). A pair of paths, with common parts
    {[
      "a/{simple => not/so/simple}/path"
    ]}

    This module is able to parse all these forms and returned a typed version of
    it. *)

type t = Vcs.Num_status.Key.t =
  | One_file of Vcs.Path_in_repo.t
  | Two_files of
      { src : Vcs.Path_in_repo.t
      ; dst : Vcs.Path_in_repo.t
      }
[@@deriving equal, sexp_of]

val parse_exn : string -> t
