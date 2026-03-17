(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module T = Vcs.Tag_name
include T
include Comparable.Make (T)

let hash t = String.hash (T.to_string t)
let hash_fold_t state t = String.hash_fold_t state (T.to_string t)
