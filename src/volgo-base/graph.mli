(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

module Node : sig
  type t = Vcs.Graph.Node.t [@@deriving hash]

  include module type of Vcs.Graph.Node with type t := t
  include Comparable.S with type t := t
end

module Descendance : sig
  type t = Vcs.Graph.Descendance.t =
    | Same_node
    | Strict_ancestor
    | Strict_descendant
    | Other
  [@@deriving hash]

  include module type of Vcs.Graph.Descendance with type t := t
end

include
  module type of Vcs.Graph
  with module Node := Vcs.Graph.Node
   and module Descendance := Vcs.Graph.Descendance
