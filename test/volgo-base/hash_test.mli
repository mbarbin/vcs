(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

module type H = sig
  type t

  val to_dyn : t -> Dyn.t
  val hash : t -> int
  val seeded_hash : int -> t -> int
end

val run
  :  (module H with type t = 'a)
  -> (module Ppx_hash_lib.Hashable.S with type t = 'a)
  -> 'a list
  -> unit
