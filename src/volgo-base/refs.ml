(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Line = struct
  type t = Vcs.Refs.Line.t =
    { rev : Rev.t
    ; ref_kind : Ref_kind.t
    }

  include (Vcs.Refs.Line : module type of Vcs.Refs.Line with type t := t)
end

type t = Line.t list

include (
  Vcs.Refs : module type of Vcs.Refs with type t := t and module Line := Vcs.Refs.Line)

let tags t = Set.of_list (module Tag_name) (Vcs.Refs.tags t)
let local_branches t = Set.of_list (module Branch_name) (Vcs.Refs.local_branches t)

let remote_branches t =
  Set.of_list (module Remote_branch_name) (Vcs.Refs.remote_branches t)
;;

let to_map (t : t) =
  List.fold
    t
    ~init:(Map.empty (module Ref_kind))
    ~f:(fun acc { rev; ref_kind } -> Map.add_exn acc ~key:ref_kind ~data:rev)
;;
