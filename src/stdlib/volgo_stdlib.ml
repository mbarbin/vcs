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

(* Some functions are copied from [Base] version [v0.17] which is released
   under MIT and may be found at [https://github.com/janestreet/base].

   See Base's LICENSE below:

   ----------------------------------------------------------------------------

   The MIT License

   Copyright (c) 2016--2024 Jane Street Group, LLC <opensource-contacts@janestreet.com>

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.

   ----------------------------------------------------------------------------

   When this is the case, we clearly indicate it next to the copied function. *)

open! Stdlib_compat
module Code_error = Code_error
module Dyn = Dyn0

module Dynable = struct
  module type S = sig
    type t

    val to_dyn : t -> Dyn.t
  end
end

let print pp = Format.printf "%a@." Pp.to_fmt pp
let print_dyn dyn = print (Dyn.pp dyn)
let phys_equal a b = a == b

module Ordering = struct
  include Ordering

  let to_dyn = function
    | Lt -> Dyn.Variant ("Lt", [])
    | Eq -> Dyn.Variant ("Eq", [])
    | Gt -> Dyn.Variant ("Gt", [])
  ;;
end

module Sexp = struct
  include Sexp

  let rec to_dyn = function
    | Sexp.Atom s -> Dyn.variant "Atom" [ Dyn.string s ]
    | Sexp.List l -> Dyn.variant "List" [ Dyn.list to_dyn l ]
  ;;
end

module type To_sexpable = sig
  type t

  val sexp_of_t : t -> Sexp.t
end

let sexp_field' (type a) (sexp_of_a : a -> Sexp.t) field a =
  Sexp.List [ Atom field; sexp_of_a a ]
;;

let sexp_field (type a) (module M : To_sexpable with type t = a) field a =
  sexp_field' M.sexp_of_t field a
;;

module Absolute_path = struct
  include Absolute_path

  let to_dyn t = Dyn.string (Absolute_path.to_string t)
end

module Array = struct
  include ArrayLabels

  let sexp_of_t = Sexplib0.Sexp_conv.sexp_of_array
  let create ~len a = make len a

  let filter_mapi t ~f =
    let out_count = ref 0 in
    let out = ref [] in
    iteri t ~f:(fun i a ->
      match f i a with
      | None -> ()
      | Some e ->
        incr out_count;
        out := e :: !out);
    match !out with
    | [] -> [||]
    | hd :: _ ->
      let out_count = !out_count in
      let res = create ~len:out_count hd in
      List.iteri (fun i a -> res.(out_count - 1 - i) <- a) !out;
      res
  ;;

  let rev a =
    let len = length a in
    let res = create ~len a.(0) in
    iteri a ~f:(fun i x -> res.(len - 1 - i) <- x);
    res
  ;;

  let sort t ~compare = sort t ~cmp:compare
end

module Bool = struct
  include Bool

  let to_dyn = Dyn.bool
end

module Char = struct
  include Char

  let is_alphanum = function
    | 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' -> true
    | _ -> false
  ;;

  let is_whitespace = function
    | '\t' | '\n' | '\011' (* vertical tab *) | '\012' (* form feed *) | '\r' | ' ' ->
      true
    | _ -> false
  ;;
end

module Hashtbl = struct
  include (
    MoreLabels.Hashtbl :
      module type of MoreLabels.Hashtbl with module Make := MoreLabels.Hashtbl.Make)

  module type S_extended = sig
    include MoreLabels.Hashtbl.S

    val add_exn : 'a t -> key:key -> data:'a -> unit
    val add_multi : 'a list t -> key:key -> data:'a -> unit
    val find : 'a t -> key -> 'a option
    val set : 'a t -> key:key -> data:'a -> unit
  end

  exception E of Sexp.t

  let () =
    Sexplib0.Sexp_conv.Exn_converter.add [%extension_constructor E] (function
      | E sexp -> sexp
      | _ -> assert false)
  ;;

  module Make (H : sig
      include Hashtbl.HashedType

      val sexp_of_t : t -> Sexp.t
    end) =
  struct
    include MoreLabels.Hashtbl.Make (H)

    let add_exn t ~key ~data =
      if mem t key
      then
        raise
          (E
             (List
                [ Atom "Hashtbl.add_exn: key already present"
                ; sexp_field (module H) "key" key
                ]))
      else add t ~key ~data
    ;;

    let add_multi t ~key ~data =
      let data =
        match find_opt t key with
        | None -> [ data ]
        | Some l -> data :: l
      in
      replace t ~key ~data
    ;;

    let find = find_opt
    let set = replace
  end
end

module Int = struct
  include Int

  let incr = incr
  let max_value = max_int
  let of_string_opt = int_of_string_opt

  let to_string_hum n =
    let s = string_of_int n in
    let len = String.length s in
    let is_negative = n < 0 in
    let sign_count = if is_negative then 1 else 0 in
    let absolute_digit_count = if is_negative then len - 1 else len in
    let separator_count = absolute_digit_count / 3 in
    let initial_skip_count =
      let digit_skip = absolute_digit_count mod 3 in
      sign_count + if digit_skip > 0 then digit_skip else 3
    in
    let buffer = Buffer.create (len + separator_count) in
    let rec aux i count =
      if i < len
      then
        if count = 0
        then (
          Buffer.add_char buffer '_';
          aux i 3)
        else (
          Buffer.add_char buffer s.[i];
          aux (i + 1) (count - 1))
    in
    aux 0 initial_skip_count;
    Buffer.contents buffer
  ;;

  let to_dyn t = Dyn.Int t
  let sexp_of_t t = Sexp.Atom (to_string_hum t)
end

module List = struct
  include ListLabels

  let sexp_of_t = Sexplib0.Sexp_conv.sexp_of_list
  let concat_map t ~f = concat_map ~f t
  let dedup_and_sort t ~compare = sort_uniq t ~cmp:compare

  let hd = function
    | [] -> None
    | hd :: _ -> Some hd
  ;;

  let filter_opt t = filter_map t ~f:Fun.id
  let find t ~f = find_opt t ~f
  let fold t ~init ~f = fold_left ~f ~init t
  let iter t ~f = iter t ~f
  let sort t ~compare = sort t ~cmp:compare
  let count t ~f = fold t ~init:0 ~f:(fun acc e -> acc + if f e then 1 else 0)
end

module Option = struct
  include Option

  let sexp_of_t = Sexplib0.Sexp_conv.sexp_of_option
  let iter t ~f = iter f t
  let map t ~f = map f t
  let some_if cond a = if cond then Some a else None
end

module Queue = struct
  include Queue

  let enqueue t a = push a t
  let to_list t = t |> to_seq |> List.of_seq
end

module Relative_path = struct
  include Relative_path

  let to_dyn t = Dyn.string (Relative_path.to_string t)
end

module Result = struct
  type ('a, 'b) t = ('a, 'b) Result.t =
    | Ok of 'a
    | Error of 'b

  let sexp_of_t sexp_of_a sexp_of_b = function
    | Ok a -> Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "Ok"; sexp_of_a a ]
    | Error b -> Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "Error"; sexp_of_b b ]
  ;;

  include (Result : module type of Result with type ('a, 'b) t := ('a, 'b) t)

  module Syntax = struct
    let ( let* ) = Result.bind
  end

  let map t ~f = map f t
  let map_error t ~f = map_error f t

  let of_option t ~error =
    match t with
    | Some v -> Ok v
    | None -> Error error
  ;;

  let return = ok
end

module String = struct
  include StringLabels

  let to_dyn = Dyn.string
  let sexp_of_t = Sexplib0.Sexp_conv.sexp_of_string
  let to_string t = t

  let chop_prefix t ~prefix =
    if starts_with ~prefix t
    then (
      let prefix_len = length prefix in
      Some (sub t ~pos:prefix_len ~len:(length t - prefix_len)))
    else None
  ;;

  let chop_suffix t ~suffix =
    if ends_with ~suffix t
    then Some (sub t ~pos:0 ~len:(length t - length suffix))
    else None
  ;;

  let is_empty t = length t = 0

  let lsplit2 t ~on =
    match index_from_opt t 0 on with
    | None -> None
    | Some i -> Some (sub t ~pos:0 ~len:i, sub t ~pos:(i + 1) ~len:(length t - i - 1))
  ;;

  let rsplit2 t ~on =
    let len = length t in
    match rindex_from_opt t (len - 1) on with
    | None -> None
    | Some i -> Some (sub t ~pos:0 ~len:i, sub t ~pos:(i + 1) ~len:(len - i - 1))
  ;;

  (* The function [split_lines] below was copied from [Base.String0.split_lines]
     version [v0.17] which is released under MIT and may be found at
     [https://github.com/janestreet/base].

     The changes we made were minimal:

     - Changed references to [Char0] to [Char].

     See notice at the top of the file and project global notice for licensing
     information. *)

  let split_lines =
    let back_up_at_newline ~t ~pos ~eol =
      pos := !pos - if !pos > 0 && Char.equal t.[!pos - 1] '\r' then 2 else 1;
      eol := !pos + 1
    in
    fun t ->
      let n = length t in
      if n = 0
      then []
      else (
        (* Invariant: [-1 <= pos < eol]. *)
        let pos = ref (n - 1) in
        let eol = ref n in
        let ac = ref [] in
        (* We treat the end of the string specially, because if the string ends with a
           newline, we don't want an extra empty string at the end of the output. *)
        if Char.equal t.[!pos] '\n' then back_up_at_newline ~t ~pos ~eol;
        while !pos >= 0 do
          if not (Char.equal t.[!pos] '\n')
          then decr pos
          else (
            (* Because [pos < eol], we know that [start <= eol]. *)
            let start = !pos + 1 in
            ac := sub t ~pos:start ~len:(!eol - start) :: !ac;
            back_up_at_newline ~t ~pos ~eol)
        done;
        sub t ~pos:0 ~len:!eol :: !ac)
  ;;

  (* ---------------------------------------------------------------------------- *)

  let split t ~on = split_on_char ~sep:on t
  let strip = trim
  let uncapitalize = uncapitalize_ascii
end

module With_equal_and_dyn = struct
  module type S = sig
    type t

    val equal : t -> t -> bool
    val to_dyn : t -> Dyn.t
  end
end

let require cond = if not cond then failwith "Required condition does not hold."

let require_does_raise f =
  match f () with
  | _ -> Code_error.raise "Did not raise." []
  | exception e -> print_endline (Stdlib.Printexc.to_string e)
;;

let require_equal
      (type a)
      (module M : With_equal_and_dyn.S with type t = a)
      (v1 : a)
      (v2 : a)
  =
  if not (M.equal v1 v2)
  then Code_error.raise "Values are not equal." [ "v1", M.to_dyn v1; "v2", M.to_dyn v2 ]
;;

let require_not_equal
      (type a)
      (module M : With_equal_and_dyn.S with type t = a)
      (v1 : a)
      (v2 : a)
  =
  if M.equal v1 v2
  then Code_error.raise "Values are equal." [ "v1", M.to_dyn v1; "v2", M.to_dyn v2 ]
;;

(* {1 Transition API} *)

let print_endline = Stdlib.print_endline
let print_s sexp = print_endline (Sexp.to_string_hum sexp)
let print_string = Stdlib.print_string
