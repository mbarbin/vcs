(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module type S = Validated_string_intf.S
module type X = Validated_string_intf.X

module Make (X : X) = struct
  let to_string t = t

  let of_string s =
    if X.invariant s
    then Ok s
    else (
      let shown_s =
        if String.length s > 40
        then
          String.sub s ~pos:0 ~len:40
          ^ "..."
          ^ Printf.sprintf " (%d characters total)" (String.length s)
        else s
      in
      Error
        (`Msg
            (Printf.sprintf "%S: invalid %s" shown_s (String.uncapitalize X.module_name))))
  ;;

  let v s =
    match of_string s with
    | Ok t -> t
    | Error (`Msg m) -> raise (Invalid_argument m)
  ;;
end
