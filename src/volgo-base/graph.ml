(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Node = struct
  module T = Vcs.Graph.Node
  include T
  include Comparable.Make (T)

  let hash t = Int.hash (Vcs.Graph.node_index t)
  let hash_fold_t state t = Int.hash_fold_t state (Vcs.Graph.node_index t)
end

module Descendance = struct
  module T0 = struct
    type t = Vcs.Graph.Descendance.t =
      | Same_node
      | Strict_ancestor
      | Strict_descendant
      | Other
    [@@deriving hash]
  end

  include (
    Vcs.Graph.Descendance : module type of Vcs.Graph.Descendance with type t := T0.t)

  include T0
end

include (
  Vcs.Graph :
    module type of Vcs.Graph
    with module Node := Vcs.Graph.Node
     and module Descendance := Vcs.Graph.Descendance)
