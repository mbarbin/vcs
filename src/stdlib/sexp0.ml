(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

include Sexp

let rec to_dyn = function
  | Sexp.Atom s -> Dyn.variant "Atom" [ Dyn.string s ]
  | Sexp.List l -> Dyn.variant "List" [ Dyn.list to_dyn l ]
;;
