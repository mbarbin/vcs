(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

include Container_key.String_impl

let invariant t =
  Int.equal (String.length t) 40
  && String.for_all t ~f:(fun c -> Char.is_alphanum c || Char.equal c '-')
;;

include Validated_string.Make (struct
    let module_name = "Rev"
    let invariant = invariant
  end)
