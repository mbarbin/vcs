(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type t =
  | Bitbucket
  | Codeberg
  | GitHub
  | GitLab
  | Sourcehut

let all = ([ Bitbucket; Codeberg; GitHub; GitLab; Sourcehut ] : t list)

let variant_constructor_name = function
  | Bitbucket -> "Bitbucket"
  | Codeberg -> "Codeberg"
  | GitHub -> "GitHub"
  | GitLab -> "GitLab"
  | Sourcehut -> "Sourcehut"
;;

let to_dyn t = Dyn.Variant (variant_constructor_name t, [])
let sexp_of_t t = Sexplib0.Sexp.Atom (variant_constructor_name t)
let compare = (compare : t -> t -> int)
let equal = (( = ) : t -> t -> bool)
let seeded_hash = (Hashtbl.seeded_hash : int -> t -> int)
let hash = (Hashtbl.hash : t -> int)

let to_string = function
  | Bitbucket -> "Bitbucket"
  | Codeberg -> "Codeberg"
  | GitHub -> "GitHub"
  | GitLab -> "GitLab"
  | Sourcehut -> "Sourcehut"
;;
