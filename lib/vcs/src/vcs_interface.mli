(*_******************************************************************************)
(*_  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*_  Copyright (C) 2024 Mathieu Barbin <mathieu.barbin@gmail.com>               *)
(*_                                                                             *)
(*_  This file is part of Vcs.                                                  *)
(*_                                                                             *)
(*_  Vcs is free software; you can redistribute it and/or modify it under       *)
(*_  the terms of the GNU Lesser General Public License as published by the     *)
(*_  Free Software Foundation either version 3 of the License, or any later     *)
(*_  version, with the LGPL-3.0 Linking Exception.                              *)
(*_                                                                             *)
(*_  Vcs is distributed in the hope that it will be useful, but WITHOUT ANY     *)
(*_  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*_  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*_  the file `NOTICE.md` at the root of this repository for more details.      *)
(*_                                                                             *)
(*_  You should have received a copy of the GNU Lesser General Public License   *)
(*_  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*_  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*_******************************************************************************)

(** Common interfaces used in [Vcs].

    This file is configured in [dune] as an interface only file, so we don't need to
    duplicate the interfaces it contains into an [ml] file. *)

module type Process_S0 = sig
  (** Helpers to wrap process outputs. *)

  type process_output
  type 'a result

  val exit0 : process_output -> unit result
  val exit0_and_stdout : process_output -> string result

  (** A convenient wrapper to write exhaustive match on a result conditioned by
      a list of accepted exit codes. If the exit code is not part of the
      accepted list, the function takes care of returning an error of the
      expected result type. *)
  val exit_code : process_output -> accept:(int * 'a) list -> 'a result
end

module type Process_S = Process_S0 with type process_output := Git_output0.t

module type S = sig
  (** The interface exported by [Vcs].

      ['a result] is the identity for the raising API, or a type based on
      [Result] depending on the API selected by the user in the non-raising
      APIs.

      The individual functions are documented in the {!module:Vcs} module. *)

  type 'a result

  val init : 'a * < 'a Trait.Init.t ; .. > -> path:Absolute_path.t -> Repo_root.t result

  val find_enclosing_git_repo_root
    :  'a * < 'a Trait.File_system.t ; .. >
    -> from:Absolute_path.t
    -> Repo_root.t option result

  val find_enclosing_repo_root
    :  'a * < 'a Trait.File_system.t ; .. >
    -> from:Absolute_path.t
    -> store:(Fsegment.t * 'store) list
    -> ('store * Repo_root.t) option result

  val add
    :  'a * < 'a Trait.Add.t ; .. >
    -> repo_root:Repo_root.t
    -> path:Path_in_repo.t
    -> unit result

  val commit
    :  'a * < 'a Trait.Rev_parse.t ; 'a Trait.Commit.t ; .. >
    -> repo_root:Repo_root.t
    -> commit_message:Commit_message.t
    -> Rev.t result

  val current_branch
    :  'a * < 'a Trait.Rev_parse.t ; .. >
    -> repo_root:Repo_root.t
    -> Branch_name.t result

  val current_revision
    :  'a * < 'a Trait.Rev_parse.t ; .. >
    -> repo_root:Repo_root.t
    -> Rev.t result

  val ls_files
    :  'a * < 'a Trait.Ls_files.t ; .. >
    -> repo_root:Repo_root.t
    -> below:Path_in_repo.t
    -> Path_in_repo.t list result

  val show_file_at_rev
    :  'a * < 'a Trait.Show.t ; .. >
    -> repo_root:Repo_root.t
    -> rev:Rev.t
    -> path:Path_in_repo.t
    -> [ `Present of File_contents.t | `Absent ] result

  val load_file
    :  'a * < 'a Trait.File_system.t ; .. >
    -> path:Absolute_path.t
    -> File_contents.t result

  val save_file
    :  ?perms:int
    -> 'a * < 'a Trait.File_system.t ; .. >
    -> path:Absolute_path.t
    -> file_contents:File_contents.t
    -> unit result

  val read_dir
    :  'a * < 'a Trait.File_system.t ; .. >
    -> dir:Absolute_path.t
    -> Fsegment.t list result

  val rename_current_branch
    :  'a * < 'a Trait.Branch.t ; .. >
    -> repo_root:Repo_root.t
    -> to_:Branch_name.t
    -> unit result

  val name_status
    :  'a * < 'a Trait.Name_status.t ; .. >
    -> repo_root:Repo_root.t
    -> changed:Name_status.Changed.t
    -> Name_status.t result

  val num_status
    :  'a * < 'a Trait.Num_status.t ; .. >
    -> repo_root:Repo_root.t
    -> changed:Num_status.Changed.t
    -> Num_status.t result

  val log : 'a * < 'a Trait.Log.t ; .. > -> repo_root:Repo_root.t -> Log.t result
  val refs : 'a * < 'a Trait.Refs.t ; .. > -> repo_root:Repo_root.t -> Refs.t result

  val graph
    :  'a * < 'a Trait.Log.t ; 'a Trait.Refs.t ; .. >
    -> repo_root:Repo_root.t
    -> Graph.t result

  val set_user_name
    :  'a * < 'a Trait.Config.t ; .. >
    -> repo_root:Repo_root.t
    -> user_name:User_name.t
    -> unit result

  val set_user_email
    :  'a * < 'a Trait.Config.t ; .. >
    -> repo_root:Repo_root.t
    -> user_email:User_email.t
    -> unit result

  (** See the note in {!val:Vcs.git} about error handling with respect to
      exceptions raised by [f].

      Some helpers dedicated to the corresponding result type are provided by
      the module {!module:Vcs.Git}. They are convenient to use to build the [f]
      parameter. *)
  val git
    :  ?env:string array
    -> ?run_in_subdir:Path_in_repo.t
    -> 'v * < 'v Trait.Git.t ; .. >
    -> repo_root:Repo_root.t
    -> args:string list
    -> f:(Git_output0.t -> 'a result)
    -> 'a result
end

module type Error_S = sig
  (** Interface used to build non raising interfaces to [Vcs] via
      [Vcs.Non_raising.Make]. *)

  (** [t] must represent the type of errors in your monad. *)
  type t [@@deriving sexp_of]

  (** The conversion functions you need to provide. *)

  val of_err : Err.t -> t
  val to_err : t -> Err.t
end
