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
    || Char.is_whitespace c
    || Char.equal '<' c
    || Char.equal '>' c
    || Char.equal '@' c
    || Char.equal '.' c)
;;

include Validated_string.Make (struct
    let module_name = "Author"
    let invariant = invariant
  end)

let of_user_config ~user_name ~user_email =
  Printf.sprintf
    "%s <%s>"
    (user_name |> User_name.to_string)
    (user_email |> User_email.to_string)
;;
