(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Int = struct
  include Int

  let hash : int -> int = Hashtbl.hash
  let seeded_hash : int -> int -> int = Hashtbl.seeded_hash
end

module ListLabels = struct
  include ListLabels

  let is_empty = function
    | [] -> true
    | _ :: _ -> false
  ;;
end

module String = struct
  include String

  let hash : string -> int = Hashtbl.hash
  let seeded_hash : int -> string -> int = Hashtbl.seeded_hash
end

module StringLabels = struct
  include StringLabels

  let hash : string -> int = Hashtbl.hash
  let seeded_hash : int -> string -> int = Hashtbl.seeded_hash
end
