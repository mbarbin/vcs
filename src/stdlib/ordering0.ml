(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

include Ordering

let to_dyn = function
  | Lt -> Dyn.Variant ("Lt", [])
  | Eq -> Dyn.Variant ("Eq", [])
  | Gt -> Dyn.Variant ("Gt", [])
;;
