(*******************************************************************************)
(*  Volgo - a Versatile OCaml Library for Git Operations                       *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
(*                                                                             *)
(*  This file is part of Volgo.                                                *)
(*                                                                             *)
(*  Volgo is free software; you can redistribute it and/or modify it under     *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Volgo is distributed in the hope that it will be useful, but WITHOUT ANY   *)
(*  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*  the file `NOTICE.md` at the root of this repository for more details.      *)
(*                                                                             *)
(*  You should have received a copy of the GNU Lesser General Public License   *)
(*  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*******************************************************************************)

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
