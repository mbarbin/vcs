(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

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
