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

type +'a t constraint 'a = < .. >

val create : 'a -> 'a t

include Vcs_intf.S with type 'a t := 'a t and type 'a result := 'a

module Private : sig
  (** This function is exposed to simplify the implementation of the [git]
      function in the non-raising APIs of Vcs. *)
  val git
    :  ?env:string array
    -> ?run_in_subdir:Path_in_repo.t
    -> < Trait.git ; .. > t
    -> repo_root:Repo_root.t
    -> args:string list
    -> f:(Git.Output.t -> ('a, Err.t) Result.t)
    -> ('a, Err.t) Result.t

  (** Build the context for errors happening during [git]. *)
  val make_git_err_step
    :  ?env:string array
    -> ?run_in_subdir:Path_in_repo.t
    -> repo_root:Repo_root.t
    -> args:string list
    -> unit
    -> Sexp.t

  (** This function is exposed to simplify the implementation of the [hg]
      function in the non-raising APIs of Vcs. *)
  val hg
    :  ?env:string array
    -> ?run_in_subdir:Path_in_repo.t
    -> < Trait.hg ; .. > t
    -> repo_root:Repo_root.t
    -> args:string list
    -> f:(Hg.Output.t -> ('a, Err.t) Result.t)
    -> ('a, Err.t) Result.t

  (** Build the context for errors happening during [hg]. *)
  val make_hg_err_step
    :  ?env:string array
    -> ?run_in_subdir:Path_in_repo.t
    -> repo_root:Repo_root.t
    -> args:string list
    -> unit
    -> Sexp.t
end
