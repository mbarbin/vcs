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

module List = struct
  include ListLabels

  let map t ~f = map ~f t
end

include Dyn

let inline_record cons fields = Dyn.variant cons [ Dyn.record fields ]

let to_sexp =
  let module Sexp = Sexplib0.Sexp in
  let module S = Sexplib0.Sexp_conv in
  let rec aux (dyn : Dyn.t) : Sexp.t =
    match[@coverage off] dyn with
    | Opaque -> Atom "<opaque>"
    | Unit -> List []
    | Int i -> S.sexp_of_int i
    | Int32 i -> S.sexp_of_int32 i
    | Record fields ->
      List (List.map fields ~f:(fun (field, t) -> Sexp.List [ Atom field; aux t ]))
    | Variant (v, args) ->
      (* Special pretty print of variants holding records. *)
      (match args with
       | [] -> Atom v
       | [ Record fields ] ->
         List
           (Atom v
            :: List.map fields ~f:(fun (field, t) -> Sexp.List [ Atom field; aux t ]))
       | _ -> List (Atom v :: List.map args ~f:aux))
    | Bool b -> S.sexp_of_bool b
    | String a -> S.sexp_of_string a
    | Bytes a -> S.sexp_of_bytes a
    | Int64 i -> S.sexp_of_int64 i
    | Nativeint i -> S.sexp_of_nativeint i
    | Char c -> S.sexp_of_char c
    | Float f -> S.sexp_of_float f
    | Option o -> S.sexp_of_option aux o
    | List l -> S.sexp_of_list aux l
    | Array a -> S.sexp_of_array aux a
    | Tuple t -> List (List.map t ~f:aux)
    | Map m -> List (List.map m ~f:(fun (k, v) -> Sexp.List [ aux k; aux v ]))
    | Set s -> List (List.map s ~f:aux)
  in
  aux
;;

type json =
  [ `Null
  | `Bool of bool
  | `Int of int
  | `Float of float
  | `String of string
  | `Assoc of (string * json) list
  | `List of json list
  ]

let to_json =
  (* JavaScript's Number.MAX_SAFE_INTEGER = 2^53 - 1. We use Int64 literals to
     avoid overflow on 32-bit architectures. To verify these values, run:
     [node -p "Number.MAX_SAFE_INTEGER"] and [node -p "Number.MIN_SAFE_INTEGER"]. *)
  let max_safe_int64 = 9007199254740991L in
  let min_safe_int64 = -9007199254740991L in
  let rec aux (dyn : Dyn.t) : json =
    match[@coverage off] dyn with
    | Opaque -> `String "<opaque>"
    | Unit -> `Null
    | Int i ->
      let i64 = Int64.of_int i in
      if i64 >= min_safe_int64 && i64 <= max_safe_int64
      then `Int i
      else `String (Int.to_string i)
    | Int32 i ->
      (* On 32-bit architectures, Int32 (32 bits) may not fit in int (31 bits). *)
      let i' = Int32.to_int i in
      if Int32.equal (Int32.of_int i') i then `Int i' else `String (Int32.to_string i)
    | Int64 i -> `String (Int64.to_string i)
    | Nativeint i -> `String (Nativeint.to_string i)
    | Bool b -> `Bool b
    | String s -> `String s
    | Bytes b -> `String (Bytes.to_string b)
    | Char c -> `String (String.make 1 c)
    | Float f -> `Float f
    | Option None -> `Null
    | Option (Some t) -> aux t
    | List l -> `List (List.map l ~f:aux)
    | Array a -> `List (Array.to_list a |> List.map ~f:aux)
    | Tuple t -> `List (List.map t ~f:aux)
    | Record fields -> `Assoc (List.map fields ~f:(fun (k, v) -> k, aux v))
    | Variant (v, []) -> `String v
    | Variant (v, [ Record fields ]) ->
      (* Special treatment for inline records: include variant name as a field. *)
      `Assoc (("type", `String v) :: List.map fields ~f:(fun (k, v) -> k, aux v))
    | Variant (v, args) -> `Assoc [ v, `List (List.map args ~f:aux) ]
    | Map m ->
      (* If all keys are strings, serialize as a JSON object. *)
      let string_keys =
        List.filter_map m ~f:(fun (k, v) ->
          match k with
          | String s -> Some (s, v)
          | _ -> None)
      in
      if List.length string_keys = List.length m
      then `Assoc (List.map string_keys ~f:(fun (k, v) -> k, aux v))
      else `List (List.map m ~f:(fun (k, v) -> `List [ aux k; aux v ]))
    | Set s -> `List (List.map s ~f:aux)
  in
  aux
;;
