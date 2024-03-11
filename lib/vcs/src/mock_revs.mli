(*_******************************************************************************)
(*_  Vcs - a versatile OCaml library for Git interaction                        *)
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

(** Maintaining a mapping between mock revs and actual revs.

    This is used to build reproducible tests. *)

(** [t] is a mutable data structure that holds a bidirectional mapping between
    actual and mock revisions. *)
type t

val create : unit -> t

(** Generate a new mock rev, not bound to any particular actual revision. *)
val next : t -> Rev.t

(** Add a binding between a revision and a mock revision. This raises if such
    revisions are already bound in [t]. *)
val add_exn : t -> rev:Rev.t -> mock_rev:Rev.t -> unit

(** Given a revision of an actual repository, resolve it and return the mock
    revision that is bound to it in [t]. If this rev isn't bound to any mock rev in
    [t] yet, this function will call [next] to build a new mock revision, bind
    it in [t] and return it. *)
val to_mock : t -> rev:Rev.t -> Rev.t

(** Return the revision bound to the given mock rev, or [None] if this mock
    revision is unbound. *)
val of_mock : t -> mock_rev:Rev.t -> Rev.t option
