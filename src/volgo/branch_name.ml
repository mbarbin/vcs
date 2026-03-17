(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

include Container_key.String_impl

let invariant t =
  (not (String.is_empty t))
  && String.for_all t ~f:(fun c ->
    Char.is_alphanum c
    || Char.equal c '-'
    || Char.equal c '_'
    || Char.equal c '.'
    || Char.equal c '+'
    || Char.equal c '@'
    || Char.equal c '#'
    || Char.equal c '/')
;;

include Validated_string.Make (struct
    let module_name = "Branch_name"
    let invariant = invariant
  end)

let main = "main"
let master = "master"
