(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

type t = Vcs.Remote_branch_name.t =
  { remote_name : Remote_name.t
  ; branch_name : Branch_name.t
  }
[@@deriving hash]

include module type of Vcs.Remote_branch_name with type t := t
include Comparable.S with type t := t
