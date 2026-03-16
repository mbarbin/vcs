(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

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
