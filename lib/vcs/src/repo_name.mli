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

(** The name of a repository as configured on a platform such as GitHub.

    This is the basename of the repository, usually composed of alphanumeric
    characters as well as a few special supported characters such as ['-'] or
    ['_'].

    On GitHub, the name of a repository is the last part of the URL, e.g.
    [https://github.com/$USER_HANDLE/$REPO_NAME]. For example, the repository
    that lives at the url {{:https://github.com/mbarbin/vcs} https://github.com/mbarbin/vcs}
    has a repo name equals to: [Repo_name.v "vcs"].

    This module is part of the [Vcs] library for convenience. Note that on
    GitHub, multiple users may have a fork of the same repo, and thus the
    repo_name on its own is not sufficient to uniquely define a given
    repository. For this, the GitHub {!module:User_handle} must be added. See
    {!module:Url} for a complete url to a repository. *)

type t [@@deriving compare, equal, hash, sexp_of]

include Comparable.S with type t := t
include Validated_string.S with type t := t
