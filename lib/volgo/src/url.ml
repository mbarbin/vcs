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

open! Import

module Protocol = struct
  [@@@coverage off]

  type t =
    | Ssh
    | Https
  [@@deriving enumerate, sexp_of]

  let compare = (compare : t -> t -> int)
  let equal = (( = ) : t -> t -> bool)

  [@@@coverage on]

  let seeded_hash = (Hashtbl.seeded_hash : int -> t -> int)
  let hash = (Hashtbl.hash : t -> int)

  let to_string t ~(platform : Platform.t) =
    match platform, t with
    | GitHub, Ssh -> "git@github.com:"
    | GitHub, Https -> "https://github.com/"
  ;;
end

[@@@coverage off]

type t =
  { platform : Platform.t
  ; protocol : Protocol.t
  ; user_handle : User_handle.t
  ; repo_name : Repo_name.t
  }
[@@deriving sexp_of]

let compare =
  (fun a__005_ b__006_ ->
     if a__005_ == b__006_
     then 0
     else (
       match Platform.compare a__005_.platform b__006_.platform with
       | 0 ->
         (match Protocol.compare a__005_.protocol b__006_.protocol with
          | 0 ->
            (match User_handle.compare a__005_.user_handle b__006_.user_handle with
             | 0 -> Repo_name.compare a__005_.repo_name b__006_.repo_name
             | n -> n)
          | n -> n)
       | n -> n)
   : t -> t -> int)
;;

let equal =
  (fun a__007_ b__008_ ->
     if a__007_ == b__008_
     then true
     else
       Platform.equal a__007_.platform b__008_.platform
       && Protocol.equal a__007_.protocol b__008_.protocol
       && User_handle.equal a__007_.user_handle b__008_.user_handle
       && Repo_name.equal a__007_.repo_name b__008_.repo_name
   : t -> t -> bool)
;;

[@@@coverage on]

let seeded_hash = (Hashtbl.seeded_hash : int -> t -> int)
let hash = (Hashtbl.hash : t -> int)

let to_string t =
  let { platform; protocol; user_handle; repo_name } = t in
  let protocol = Protocol.to_string protocol ~platform in
  let user_handle = User_handle.to_string user_handle in
  let repo_name = Repo_name.to_string repo_name in
  Printf.sprintf "%s%s/%s.git" protocol user_handle repo_name
;;

let of_string (s : string) : (t, [ `Msg of string ]) Result.t =
  let open Result.Monad_syntax in
  match
    List.find_map Platform.all ~f:(fun platform ->
      List.find_map Protocol.all ~f:(fun protocol ->
        let prefix = Protocol.to_string protocol ~platform in
        Option.map (String.chop_prefix s ~prefix) ~f:(fun rest ->
          let* user_handle, rest =
            String.lsplit2 rest ~on:'/' |> Result.of_option ~error:"missing user handle"
          in
          let* repo_name =
            String.chop_suffix rest ~suffix:".git"
            |> Result.of_option ~error:"missing .git suffix"
          in
          let* user_handle =
            match User_handle.of_string user_handle with
            | Ok _ as ok -> ok
            | Error (`Msg m) -> Error m
          in
          let* repo_name =
            match Repo_name.of_string repo_name with
            | Ok _ as ok -> ok
            | Error (`Msg m) -> Error m
          in
          Result.return { platform; protocol; user_handle; repo_name })))
  with
  | Some (Ok _ as ok) -> ok
  | Some (Error e) -> Error (`Msg (Printf.sprintf "%S: invalid url. %s" s e))
  | None -> Error (`Msg (Printf.sprintf "%S: invalid url" s))
;;

let v str =
  match of_string str with
  | Ok t -> t
  | Error (`Msg m) -> raise (Invalid_argument m)
;;
