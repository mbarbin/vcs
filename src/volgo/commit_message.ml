(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

include Container_key.String_impl

let invariant t = (not (String.is_empty t)) && String.length t <= 512

include Validated_string.Make (struct
    let module_name = "Commit_message"
    let invariant = invariant
  end)
