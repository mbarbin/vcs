(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

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
