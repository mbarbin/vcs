(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module T = struct
  module T0 = struct
    type t = Vcs.Ref_kind.t =
      | Local_branch of { branch_name : Branch_name.t }
      | Remote_branch of { remote_branch_name : Remote_branch_name.t }
      | Tag of { tag_name : Tag_name.t }
      | Other of { name : string }
    [@@deriving hash]
  end

  include (Vcs.Ref_kind : module type of Vcs.Ref_kind with type t := T0.t)
  include T0
end

include T
include Comparable.Make (T)
