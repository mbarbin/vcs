(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module T = struct
  module T0 = struct
    type t = Vcs.Remote_branch_name.t =
      { remote_name : Remote_name.t
      ; branch_name : Branch_name.t
      }
    [@@deriving hash]
  end

  include (
    Vcs.Remote_branch_name : module type of Vcs.Remote_branch_name with type t := T0.t)

  include T0
end

include T
include Comparable.Make (T)
