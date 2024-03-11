(** Common command line parameters in use in vcs. *)

(** {1 Initialization} *)

module Config : sig
  type t
end

val config : Config.t Command.Param.t

module Context : sig
  type t
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

(** An anonymous parameter for an absolute path. *)
val anon_absolute_path : Absolute_path.t Or_error.t Command.Param.t

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
