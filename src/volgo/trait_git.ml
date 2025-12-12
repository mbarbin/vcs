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

module type S = sig
  type t

  val git
    :  ?env:string array
    -> t
    -> cwd:Absolute_path.t
    -> args:string list
    -> f:(Git.Output.t -> ('a, Err.t) Result.t)
    -> ('a, Err.t) Result.t
end

class type t = object
  method git :
    'a.
    ?env:string array
    -> unit
    -> cwd:Absolute_path.t
    -> args:string list
    -> f:(Git.Output.t -> ('a, Err.t) Result.t)
    -> ('a, Err.t) Result.t
end

module Make (X : S) = struct
  class c (t : X.t) =
    object
      method git
        :  'a.
           ?env:string array
        -> unit
        -> cwd:Absolute_path.t
        -> args:string list
        -> f:(Git.Output.t -> ('a, Err.t) Result.t)
        -> ('a, Err.t) Result.t =
        fun ?env () ~cwd ~args ~f -> X.git ?env t ~cwd ~args ~f
    end
end
