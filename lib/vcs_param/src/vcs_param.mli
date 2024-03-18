(*_******************************************************************************)
(*_  Vcs - a versatile OCaml library for Git interaction                        *)
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

(** Common command line parameters in use in vcs. *)

(** {1 Initialization} *)

module Config : sig
  type t

  val default : t
  val param : t Command.Param.t
end

val config : Config.t Command.Param.t

module Context : sig
  type t

  val create
    :  ?cwd:Absolute_path.t
    -> env:< fs : _ Eio.Path.t ; process_mgr : _ Eio.Process.mgr ; .. >
    -> config:Config.t
    -> unit
    -> t Or_error.t
end

module Initialized : sig
  type t =
    { vcs : Vcs_git.t'
    ; repo_root : Vcs.Repo_root.t
    ; context : Context.t
    }
end

(** The initialization should be created very early in the commands body. The
    [cwd] shall not be changed subsequently. *)
val initialize
  :  env:< fs : _ Eio.Path.t ; process_mgr : _ Eio.Process.mgr ; .. >
  -> config:Config.t
  -> Initialized.t Or_error.t

(** {1 Params}

    Some parameters may only be created under a certain context, in that case
    they're exposed wrapped under a resolvable type. Otherwise they can be
    exposed as command params directly.

    If not otherwise specified, the parameters are resolved under the current
    context, and are required. Optional parameters ends with [_optional]. *)

(** A ['a Vcs_param.t] is a command line parameter that produces a value of type
    ['a] under the initialized context. *)
type 'a t

(** To be called in the body of the command, after initialization. *)
val resolve : 'a t -> context:Context.t -> 'a Or_error.t

(** A required anon [BRANCH]. *)
val anon_branch_name : Vcs.Branch_name.t Or_error.t Command.Param.t

(** An optional anon [BRANCH]. *)
val anon_branch_name_opt : Vcs.Branch_name.t Or_error.t option Command.Param.t

(** An anonymous parameter for a path. It can be given either as an absolute
    path or relative path in the command line, but will always be resolved to an
    absolute path. *)
val anon_path : Absolute_path.t t Command.Param.t

(** An anonymous parameter for a path in repo. *)
val anon_path_in_repo : Vcs.Path_in_repo.t t Command.Param.t

(** A required anon [REV]. *)
val anon_rev : Vcs.Rev.t Or_error.t Command.Param.t

(** A flag to restrict the repo to a subdirectory below a certain path. *)
val below_path_in_repo : Vcs.Path_in_repo.t option t Command.Param.t

(** A required [-m _] nonempty commit message. *)
val commit_message : Vcs.Commit_message.t Or_error.t Command.Param.t

(** Perform the side effect if any, but suppress the output in case of success. *)
val quiet : bool Command.Param.t

(** A required [--rev _] that produces a revision. *)
val rev : Vcs.Rev.t Or_error.t Command.Param.t

val user_email : Vcs.User_email.t Or_error.t Command.Param.t
val user_name : Vcs.User_name.t Or_error.t Command.Param.t
