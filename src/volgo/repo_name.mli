(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** The name of a repository as configured on a platform such as GitHub.

    This is the basename of the repository, usually composed of alphanumeric
    characters as well as a few special supported characters such as ['-'] or
    ['_'].

    On GitHub, the name of a repository is the last part of the URL, e.g.
    [https://github.com/${USER_HANDLE}/${REPO_NAME}].

    For example, the repository that lives at the url
    {{:https://github.com/mbarbin/vcs} https://github.com/mbarbin/vcs} has a
    repo name equals to: [Repo_name.v "vcs"].

    This module is part of the [Vcs] library for convenience. Note that on
    GitHub, multiple users may have a fork of the same repo, and thus the
    repo_name on its own is not sufficient to uniquely define a given
    repository. For this, the GitHub {!module:User_handle} must be added. See
    {!module:Platform_repo.Url} for a complete url to a repository. *)

type t (** @canonical Volgo.Vcs.Repo_name.t *)

include Container_key.S with type t := t
include Validated_string.S with type t := t
