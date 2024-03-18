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

(** A versatile library for Git interaction.

    Vcs is a library providing a direct-style API for interacting with Git
    repositories in a type-safe way. It is designed as an "interface", or
    "virtual" library with the actual implementation dynamically dispatched at
    runtime.

    How it works?

    [Vcs] is an interface composed of traits, each providing different
    functionalities associated with Git interaction. The dynamic dispatch
    implementation uses the {{:https://github.com/mbarbin/provider} provider}
    library. *)

module Trait = Trait

(** At its core, a ['a Vcs.t] is a value encapsulating the functionalities
    implemented by a set of traits, represented by the ['a] parameter. It is a
    phantom type used to provide compiler guidance on which functions from the
    API you can use with such a [vcs]. The type is contravariant by its
    parameter : indeed, if you need a set of traits, having more makes is
    compatible. *)
type -'a t

(** [create provider] returns a [vcs] that implements a given set of traits.
    Typical users do not use [create] directly, but rather will rely on an
    actual provider. See for example [Vcs_git.create]. *)
val create : 'a Provider.t -> 'a t

(** {1 Error handling}

    The default API of [Vcs] is one that exposes functions that may raise a
    single exception, named {!exception:E}, which carries an abstract payload
    containing printable information, that is not meant for pattern matching
    (thus targeting only a non-specialized error recovery).

    A general design principle that we follow here is that if an error result is
    of interest for pattern matching, we want to incorporate it into the
    successful branch of the function's result, rather than in its error part -
    either by making the result a variant type, or otherwise adding more
    functions to the API with finer granularity for particular use cases.
    Consider opening an issue on [GitHub] if what you'd like to match on isn't
    available.

    As library authors we realize that manipulating [Result.t] is a popular
    choice too: we also export the [Vcs]'s functionality via
    {{!non_raising_apis} non-raising APIs} if you prefer. *)

(** Payload of the exception raised by [Vcs] functions. *)
module Err = Err

(** [E] is meant to be the only exception ever raised by functions from the
    [Vcs] interface. [Err.t] doesn't carry the raw backtrace, so you'll need
    to manipulate the backtrace yourself if you care about it (like you would
    with any other exceptions). *)
exception E of Err.t
[@@deriving sexp_of]

(** {1 Creating repositories} *)

module Platform = Platform
module Repo_name = Repo_name
module Repo_root = Repo_root
module Url = Url

(** Initialize a git repository at the given path. This errors out if a
    repository is already initialized there. *)
val init : [> Trait.init ] t -> path:Absolute_path.t -> Repo_root.t

(** {1 Revisions} *)

module Rev = Rev
module Mock_rev_gen = Mock_rev_gen
module Mock_revs = Mock_revs

(** {1 Commits} *)

module Commit_message = Commit_message
module Path_in_repo = Path_in_repo

val add : [> Trait.add ] t -> repo_root:Repo_root.t -> path:Path_in_repo.t -> unit

(** When this succeeds, this returns the revision of the commit that was just created. *)
val commit
  :  [> Trait.rev_parse | Trait.commit ] t
  -> repo_root:Repo_root.t
  -> commit_message:Commit_message.t
  -> Rev.t

(** {1 Files} *)

module File_contents = File_contents

val ls_files
  :  [> Trait.ls_files ] t
  -> repo_root:Repo_root.t
  -> below:Path_in_repo.t
  -> Path_in_repo.t list

val show_file_at_rev
  :  [> Trait.show ] t
  -> repo_root:Repo_root.t
  -> rev:Rev.t
  -> path:Path_in_repo.t
  -> [ `Present of File_contents.t | `Absent ]

(** {2 Files IO}

    Vcs contains some basic provider based functions to manipulate files from the
    file system. The goal is to allow some users of [Vcs] to use this simple API
    without committing to a particular implementation. If the [Vcs] provider used at
    runtime is based on [Eio], these functions will use [Eio.Path] underneath. *)

val load_file : [> Trait.file_system ] t -> path:Absolute_path.t -> File_contents.t

val save_file
  :  ?perms:int (** defaults to [0o600]. *)
  -> [> Trait.file_system ] t
  -> path:Absolute_path.t
  -> file_contents:File_contents.t
  -> unit

(** {1 Branches & Tags} *)

module Branch_name = Branch_name
module Remote_name = Remote_name
module Remote_branch_name = Remote_branch_name
module Tag_name = Tag_name

(** This translates to [git branch --move $NAME], which is used to enforce the
    name of a default branch during tests. If the current branch already has
    this name, this has no further effect. *)
val rename_current_branch
  :  [> Trait.branch ] t
  -> repo_root:Repo_root.t
  -> to_:Branch_name.t
  -> unit

(** {1 Computing diffs} *)

module Name_status = Name_status
module Num_status = Num_status
module Num_lines_in_diff = Num_lines_in_diff

val name_status
  :  [> Trait.name_status ] t
  -> repo_root:Repo_root.t
  -> changed:Name_status.Changed.t
  -> Name_status.t

val num_status
  :  [> Trait.num_status ] t
  -> repo_root:Repo_root.t
  -> changed:Num_status.Changed.t
  -> Num_status.t

(** {1 Manipulating the tree in memory} *)

module Log = Log
module Ref_kind = Ref_kind
module Refs = Refs
module Tree = Tree

val log : [> Trait.log ] t -> repo_root:Repo_root.t -> Log.t
val refs : [> Trait.refs ] t -> repo_root:Repo_root.t -> Refs.t
val tree : [> Trait.log | Trait.refs ] t -> repo_root:Repo_root.t -> Tree.t

(** {1 Rev parse utils} *)

module Rev_parse = Rev_parse

val rev_parse
  :  [> Trait.rev_parse ] t
  -> repo_root:Repo_root.t
  -> arg:Rev_parse.Arg.t
  -> Rev.t

(** {1 User config} *)

module Author = Author
module User_email = User_email
module User_handle = User_handle
module User_name = User_name

(** During tests in the GitHub environment we end up having issues if we do not
    set the user name and email. Also, we rather not do it globally. If this
    is never called, the current user config is used as usual by git processes
    invocations. *)

val set_user_name
  :  [> Trait.config ] t
  -> repo_root:Repo_root.t
  -> user_name:User_name.t
  -> unit

val set_user_email
  :  [> Trait.config ] t
  -> repo_root:Repo_root.t
  -> user_email:User_email.t
  -> unit

(** {1 Low level Git cli}

    This part of Vcs provides direct access to the ["git"] command line
    interface. This should be considered non portable and brittle. Generally
    speaking, one hope is that you shouldn't have to use {!val:git} directly.
    Instead, consider requesting proper integration of your use case into the
    typed and parametrized API of [Vcs]. However, sometimes this is just what
    you need e.g. in tests, or for quick one-off, and if your backend happens to
    be a [CLI] based vcs provider, we might as well expose this. Use at your own
    risk/convenience. *)

module Git = Git

val git
  :  ?env:string array
  -> ?run_in_subdir:Path_in_repo.t
  -> [> Trait.git ] t
  -> repo_root:Repo_root.t
  -> args:string list
  -> f:(Git.Output.t -> 'a)
  -> 'a

(** {1 Test utils}

    This part of Vcs provides utilities for testing. *)

module For_test : sig
  (** This takes care of setting the user config with dummy values, so that
      running [commit] doesn't fail. *)
  val init
    :  [> Trait.config | Trait.init ] t
    -> path:Absolute_path.t
    -> Repo_root.t Or_error.t
end

(** {1:non_raising_apis Non-raising APIs}

    For convenience and to allow experimenting with different error handling
    strategies, [Vcs] exports non-raising APIs. The functions there return
    [Result.t]s instead of raising. *)

module Non_raising : sig
  module type S = sig
    type err
    type 'a result := ('a, err) Result.t

    val init : [> Trait.init ] t -> path:Absolute_path.t -> Repo_root.t result

    val add
      :  [> Trait.add ] t
      -> repo_root:Repo_root.t
      -> path:Path_in_repo.t
      -> unit result

    val commit
      :  [> Trait.rev_parse | Trait.commit ] t
      -> repo_root:Repo_root.t
      -> commit_message:Commit_message.t
      -> Rev.t result

    val ls_files
      :  [> Trait.ls_files ] t
      -> repo_root:Repo_root.t
      -> below:Path_in_repo.t
      -> Path_in_repo.t list result

    val show_file_at_rev
      :  [> Trait.show ] t
      -> repo_root:Repo_root.t
      -> rev:Rev.t
      -> path:Path_in_repo.t
      -> [ `Present of File_contents.t | `Absent ] result

    val load_file
      :  [> Trait.file_system ] t
      -> path:Absolute_path.t
      -> File_contents.t result

    val save_file
      :  ?perms:int
      -> [> Trait.file_system ] t
      -> path:Absolute_path.t
      -> file_contents:File_contents.t
      -> unit result

    val rename_current_branch
      :  [> Trait.branch ] t
      -> repo_root:Repo_root.t
      -> to_:Branch_name.t
      -> unit result

    val name_status
      :  [> Trait.name_status ] t
      -> repo_root:Repo_root.t
      -> changed:Name_status.Changed.t
      -> Name_status.t result

    val num_status
      :  [> Trait.num_status ] t
      -> repo_root:Repo_root.t
      -> changed:Num_status.Changed.t
      -> Num_status.t result

    val log : [> Trait.log ] t -> repo_root:Repo_root.t -> Log.t result
    val refs : [> Trait.refs ] t -> repo_root:Repo_root.t -> Refs.t result
    val tree : [> Trait.log | Trait.refs ] t -> repo_root:Repo_root.t -> Tree.t result

    val rev_parse
      :  [> Trait.rev_parse ] t
      -> repo_root:Repo_root.t
      -> arg:Rev_parse.Arg.t
      -> Rev.t result

    val set_user_name
      :  [> Trait.config ] t
      -> repo_root:Repo_root.t
      -> user_name:User_name.t
      -> unit result

    val set_user_email
      :  [> Trait.config ] t
      -> repo_root:Repo_root.t
      -> user_email:User_email.t
      -> unit result

    val git
      :  ?env:string array
      -> ?run_in_subdir:Path_in_repo.t
      -> [> Trait.git ] t
      -> repo_root:Repo_root.t
      -> args:string list
      -> f:(Git.Output.t -> 'a result)
      -> 'a result
  end
end

(** An API based on [Base.Or_error]. *)
module Or_error : sig
  type err = Error.t
  type 'a result = 'a Or_error.t

  include Non_raising.S with type err := Error.t
end

(** An API in the style of
    {{:https://erratique.ch/software/rresult/doc/Rresult/index.html#usage} Rresult}. *)
module Result : sig
  type err = [ `Vcs of Err.t ]
  type 'a result = ('a, err) Result.t

  include Non_raising.S with type err := err

  val pp_error : Stdlib.Format.formatter -> [ `Vcs of Err.t ] -> unit
  val open_error : 'a result -> ('a, [> `Vcs of Err.t ]) Result.t
  val error_to_msg : 'a result -> ('a, [ `Msg of string ]) Result.t
end
