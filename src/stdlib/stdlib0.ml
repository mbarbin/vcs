(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Absolute_path = Absolute_path0
module Array = Array0
module Bool = Bool0
module Char = Char0
module Code_error = Code_error
module Dyn = Dyn0
module Fsegment = Fsegment0
module Hashtbl = Hashtbl0
module Int = Int0
module List = List0
module Option = Option0
module Ordering = Ordering0
module Queue = Queue0
module Relative_path = Relative_path0
module Result = Result0
module Sexp = Sexp0
module String = String0

module Dynable = struct
  module type S = sig
    type t

    val to_dyn : t -> Dyn.t
  end
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

module With_equal_and_dyn = struct
  module type S = sig
    type t

    val equal : t -> t -> bool
    val to_dyn : t -> Dyn.t
  end
end

let print pp = Format.printf "%a@." Pp.to_fmt pp
let print_dyn dyn = print (Dyn.pp dyn)
let phys_equal a b = a == b
let require cond = if not cond then failwith "Required condition does not hold."

let require_does_raise f =
  match f () with
  | _ -> Code_error.raise "Did not raise." []
  | exception e -> print_endline (Printexc.to_string e)
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

let print_s sexp = print_endline (Sexp.to_string_hum sexp)
