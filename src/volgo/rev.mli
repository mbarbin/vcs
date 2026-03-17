(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** A revision uniquely identifies a node in the dag formed by the commits of a
    repository. The name was inherited from Mercurial. For git, this
    correspond to the commit-hash. In both systems, these are 40-chars hashes. *)

type t (** @canonical Volgo.Vcs.Rev.t *)

include Container_key.S with type t := t
include Validated_string.S with type t := t
