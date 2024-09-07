(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024 Mathieu Barbin <mathieu.barbin@gmail.com>               *)
(*                                                                             *)
(*  This file is part of Vcs.                                                  *)
(*                                                                             *)
(*  Vcs is free software; you can redistribute it and/or modify it under       *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Vcs is distributed in the hope that it will be useful, but WITHOUT ANY     *)
(*  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*  the file `NOTICE.md` at the root of this repository for more details.      *)
(*                                                                             *)
(*  You should have received a copy of the GNU Lesser General Public License   *)
(*  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*******************************************************************************)

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
