(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

module type S = sig
  type t

  val hg
    :  ?env:string array
    -> t
    -> cwd:Absolute_path.t
    -> args:string list
    -> f:(Hg.Output.t -> ('a, Err.t) Result.t)
    -> ('a, Err.t) Result.t
end

class type t = object
  method hg :
    'a.
    ?env:string array
    -> unit
    -> cwd:Absolute_path.t
    -> args:string list
    -> f:(Hg.Output.t -> ('a, Err.t) Result.t)
    -> ('a, Err.t) Result.t
end

module Make (X : S) : sig
  class c : X.t -> object
    inherit t
  end
end
