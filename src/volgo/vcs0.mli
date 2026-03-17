(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

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
