(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

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

module Dynable : sig
  module type S = sig
    type t

    val to_dyn : t -> Dyn.t
  end
end

val print_dyn : Dyn.t -> unit
val phys_equal : 'a -> 'a -> bool

module type To_sexpable = sig
  type t

  val sexp_of_t : t -> Sexp.t
end

val sexp_field : (module To_sexpable with type t = 'a) -> string -> 'a -> Sexp.t
val sexp_field' : ('a -> Sexp.t) -> string -> 'a -> Sexp.t

module With_equal_and_dyn : sig
  module type S = sig
    type t

    val equal : t -> t -> bool
    val to_dyn : t -> Dyn.t
  end
end

(** {1 Test helpers} *)

val require : bool -> unit
val require_does_raise : (unit -> 'a) -> unit
val require_equal : (module With_equal_and_dyn.S with type t = 'a) -> 'a -> 'a -> unit
val require_not_equal : (module With_equal_and_dyn.S with type t = 'a) -> 'a -> 'a -> unit

(** {1 Transition API}

    Functions in this section are exported to smooth transitions and refactor as
    we rework the exact set of third-party dependencies for the volgo project.
    They may be removed or renamed in the future. *)

val print_s : Sexp.t -> unit
