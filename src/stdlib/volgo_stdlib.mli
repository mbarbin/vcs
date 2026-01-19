(*_******************************************************************************)
(*_  Volgo - a Versatile OCaml Library for Git Operations                       *)
(*_  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
(*_                                                                             *)
(*_  This file is part of Volgo.                                                *)
(*_                                                                             *)
(*_  Volgo is free software; you can redistribute it and/or modify it under     *)
(*_  the terms of the GNU Lesser General Public License as published by the     *)
(*_  Free Software Foundation either version 3 of the License, or any later     *)
(*_  version, with the LGPL-3.0 Linking Exception.                              *)
(*_                                                                             *)
(*_  Volgo is distributed in the hope that it will be useful, but WITHOUT ANY   *)
(*_  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*_  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*_  the file `NOTICE.md` at the root of this repository for more details.      *)
(*_                                                                             *)
(*_  You should have received a copy of the GNU Lesser General Public License   *)
(*_  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*_  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*_******************************************************************************)

(** Extending [Stdlib] for use in the project.

    {1 Internal Library - Not for External Use}

    This library is meant to be an internal component of the Volgo project. It
    is shared across multiple OCaml packages within the project. We have not
    found a way to mark it as private in the dune build system, but it should be
    treated as private.

    {b Warning:} In particular, this library is not intended for use outside of
    the Volgo project. Its interface is subject to breaking changes at any time,
    without following semver or any other stability and backward compatibility
    guidelines. *)

open! Stdlib_compat
module Code_error = Code_error
module Dyn = Dyn

module Dynable : sig
  module type S = sig
    type t

    val to_dyn : t -> Dyn.t
  end
end

val print_dyn : Dyn.t -> unit

module Ordering : sig
  include module type of struct
    include Ordering
  end

  val to_dyn : t -> Dyn.t
end

module Array : sig
  include module type of ArrayLabels

  val sexp_of_t : ('a -> Sexp.t) -> 'a t -> Sexp.t
  val create : len:int -> 'a -> 'a array
  val filter_mapi : 'a array -> f:(int -> 'a -> 'b option) -> 'b array
  val rev : 'a array -> 'a array
  val sort : 'a array -> compare:('a -> 'a -> int) -> unit
end

module Bool : sig
  include module type of struct
    include Stdlib.Bool
  end

  val to_dyn : t -> Dyn.t
end

module Char : sig
  include module type of Char

  val is_alphanum : char -> bool
  val is_whitespace : char -> bool
end

module Hashtbl : sig
  include module type of MoreLabels.Hashtbl with module Make := MoreLabels.Hashtbl.Make

  module type S_extended = sig
    include MoreLabels.Hashtbl.S

    val add_exn : 'a t -> key:key -> data:'a -> unit
    val add_multi : 'a list t -> key:key -> data:'a -> unit
    val find : 'a t -> key -> 'a option
    val set : 'a t -> key:key -> data:'a -> unit
  end

  module Make (H : sig
      include Hashtbl.HashedType

      val sexp_of_t : t -> Sexp.t
    end) : S_extended with type key = H.t
end

module Int : sig
  include module type of Int

  val sexp_of_t : t -> Sexp.t
  val incr : int ref -> unit
  val max_value : int
  val of_string_opt : string -> int option
  val to_string_hum : int -> string
end

module List : sig
  include module type of ListLabels

  val sexp_of_t : ('a -> Sexp.t) -> 'a t -> Sexp.t
  val concat_map : 'a list -> f:('a -> 'b list) -> 'b list
  val count : 'a list -> f:('a -> bool) -> int
  val dedup_and_sort : 'a list -> compare:('a -> 'a -> int) -> 'a list
  val filter_opt : 'a option list -> 'a list
  val find : 'a list -> f:('a -> bool) -> 'a option
  val fold : 'a list -> init:'b -> f:('b -> 'a -> 'b) -> 'b
  val hd : 'a list -> 'a option
  val iter : 'a list -> f:('a -> unit) -> unit
  val sort : 'a list -> compare:('a -> 'a -> int) -> 'a list
end

module Option : sig
  include module type of Option

  val sexp_of_t : ('a -> Sexp.t) -> 'a t -> Sexp.t
  val iter : 'a t -> f:('a -> unit) -> unit
  val map : 'a option -> f:('a -> 'b) -> 'b option
  val some_if : bool -> 'a -> 'a option
end

module Queue : sig
  include module type of Queue

  val enqueue : 'a t -> 'a -> unit
  val to_list : 'a t -> 'a list
end

module Result : sig
  include module type of Result

  module Monad_syntax : sig
    val ( let* ) : ('a, 'e) t -> ('a -> ('b, 'e) t) -> ('b, 'e) t
  end

  val sexp_of_t : ('a -> Sexp.t) -> ('b -> Sexp.t) -> ('a, 'b) Result.t -> Sexp.t
  val map : ('a, 'e) Result.t -> f:('a -> 'b) -> ('b, 'e) Result.t
  val map_error : ('a, 'e1) Result.t -> f:('e1 -> 'e2) -> ('a, 'e2) Result.t
  val of_option : 'a option -> error:'e -> ('a, 'e) Result.t
  val return : 'a -> ('a, _) Result.t
end

module String : sig
  include module type of StringLabels

  val to_dyn : t -> Dyn.t
  val sexp_of_t : t -> Sexp.t
  val to_string : string -> string
  val chop_prefix : string -> prefix:string -> string option
  val chop_suffix : string -> suffix:string -> string option
  val is_empty : string -> bool
  val lsplit2 : string -> on:char -> (string * string) option
  val rsplit2 : string -> on:char -> (string * string) option
  val split_lines : string -> string list
  val split : string -> on:char -> string list
  val strip : string -> string
  val uncapitalize : string -> string
end

val compare_bool : bool -> bool -> int
val compare_int : int -> int -> int
val compare_string : string -> string -> int
val equal_bool : bool -> bool -> bool
val equal_int : int -> int -> bool
val equal_string : string -> string -> bool
val equal_list : ('a -> 'a -> bool) -> 'a list -> 'a list -> bool
val hash_string : string -> int

(** {1 Sexp helper} *)

module type To_sexpable = sig
  type t

  val sexp_of_t : t -> Sexp.t
end

val sexp_field : (module To_sexpable with type t = 'a) -> string -> 'a -> Sexp.t
val sexp_field' : ('a -> Sexp.t) -> string -> 'a -> Sexp.t

(** {1 Test helpers} *)

module With_equal_and_dyn : sig
  module type S = sig
    type t

    val equal : t -> t -> bool
    val to_dyn : t -> Dyn.t
  end
end
