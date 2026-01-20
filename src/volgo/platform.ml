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
