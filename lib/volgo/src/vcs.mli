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

(** A Versatile Library for Git Operations.

    Vcs is a library providing a direct-style API for interacting with Git
    repositories in a type-safe way. It is designed as an interface composed of
    traits, each providing different functionalities associated with Git
    interaction.

    Vcs dynamically dispatches its implementation at runtime thanks to a design
    powered by the use of OCaml Objects under the hood, with some design
    guidelines aimed at making it so that users only need to make limited direct
    use of objects in their code. *)

module Trait = Trait

(** At its core, Vcs operates on a value encapsulating the functionalities
    implemented by a set of traits, represented by a set of classes indicating
    which functions from the API you can use with such a [vcs].

    In your interfaces, you should specify the exact list of traits you need,
    while keeping the type of the object parameter open, to make your code
    flexible and compatible with backend offering more traits than your strict
    requirements. *)
type +'a t = 'a Vcs0.t

(** [create traits] returns a [vcs] that implements a given set of traits.
    Typical users do not use [create] vcs objects directly, but rather will
    rely on helper library. See for example [Volgo_git_eio.create]. *)
val create : 'a -> 'a t

(** {1 Error handling}

    The default API of [Vcs] is one that exposes functions that may raise a
    single exception [Err.E], which carries an abstract payload [err] containing
    printable information. [err] is not meant for pattern matching - we're only
    targeting a non-specialized error recovery.

    [Err.E] is meant to be the only exception ever raised by functions from the
    [Vcs] interface. [Err.t] doesn't carry the raw backtrace, so you'll need to
    manipulate the backtrace yourself if you care about it (like you would with
    any other exceptions).

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

(** {1 Creating repositories} *)

module Platform = Platform
module Platform_repo = Platform_repo
module Repo_name = Repo_name
module Repo_root = Repo_root

(** Initialize a Git repository at the given path. This errors out if a
    repository is already initialized there. *)
val init : < Trait.init ; .. > t -> path:Absolute_path.t -> Repo_root.t

(** [find_enclosing_repo_root vcs ~from:dir ~store] walks up the path from
    the given directory [dir] and stops when at the root of a repository. If no
    repo root has been found when reaching the root path ["/"], the function
    returns [None].

    The way we determine whether we are at the root of a repo is by looking for
    the presence of one of the store entries in the directory (e.g. [".git"]).

    When present, we do not check that the store is itself a directory, so that
    this function is able to correctly infer and return the root of Git repos
    where [".git"] is not a directory (e.g. Git worktrees).

    You may supply several stores if you want to stop at the first store that is
    encountered, if you do not know in what kind of repo you are. For example,
    [[".git", `Git; ".hg", `Hg]]. The store that was matched is returned as part
    of the result.

    If you know you are in a Git repository you may want to use the wrapper
    {!val:find_enclosing_git_repo_root} instead. *)
val find_enclosing_repo_root
  :  < Trait.file_system ; .. > t
  -> from:Absolute_path.t
  -> store:(Fsegment.t * 'store) list
  -> ('store * Repo_root.t) option

(** [find_enclosing_git_repo_root vcs ~from:dir] is a convenient wrapper around
    {!val:find_enclosing_repo_root} for Git repositories. This is looking for
    the deepest directory containing a [".git"] entry, starting from [dir] and
    walking up. *)
val find_enclosing_git_repo_root
  :  < Trait.file_system ; .. > t
  -> from:Absolute_path.t
  -> Repo_root.t option

(** {1 Revisions} *)

module Rev = Rev
module Mock_rev_gen = Mock_rev_gen
module Mock_revs = Mock_revs

(** {1 Commits} *)

module Commit_message = Commit_message
module Path_in_repo = Path_in_repo

val add : < Trait.add ; .. > t -> repo_root:Repo_root.t -> path:Path_in_repo.t -> unit

(** When this succeeds, this returns the revision of the commit that was just created. *)
val commit
  :  < Trait.commit ; Trait.current_revision ; .. > t
  -> repo_root:Repo_root.t
  -> commit_message:Commit_message.t
  -> Rev.t

(** {1 Files} *)

module File_contents = File_contents

val ls_files
  :  < Trait.ls_files ; .. > t
  -> repo_root:Repo_root.t
  -> below:Path_in_repo.t
  -> Path_in_repo.t list

val show_file_at_rev
  :  < Trait.show ; .. > t
  -> repo_root:Repo_root.t
  -> rev:Rev.t
  -> path:Path_in_repo.t
  -> [ `Present of File_contents.t | `Absent ]

(** {2 Files IO}

    Vcs contains some basic backend based functions to manipulate files from the
    file system. The goal is to allow some users of [Vcs] to use this simple API
    without committing to a particular implementation. For example, if the
    backend used at runtime is based on [Eio], these functions will use
    [Eio.Path] underneath. *)

val load_file : < Trait.file_system ; .. > t -> path:Absolute_path.t -> File_contents.t

(** Create a new file, or truncate an existing one. *)
val save_file
  :  ?perms:int (** defaults to [0o666]. *)
  -> < Trait.file_system ; .. > t
  -> path:Absolute_path.t
  -> file_contents:File_contents.t
  -> unit

(** Returns the entries of the supplied directory, ordered increasingly
    according to [String.compare]. The result does not include the unix entries
    ".", "..". *)
val read_dir : < Trait.file_system ; .. > t -> dir:Absolute_path.t -> Fsegment.t list

(** {1 Branches & Tags} *)

module Branch_name = Branch_name
module Remote_name = Remote_name
module Remote_branch_name = Remote_branch_name
module Tag_name = Tag_name

(** This translates to [git branch --move $NAME], which is used to enforce the
    name of a default branch during tests. If the current branch already has
    this name, this has no further effect. *)
val rename_current_branch
  :  < Trait.branch ; .. > t
  -> repo_root:Repo_root.t
  -> to_:Branch_name.t
  -> unit

(** {1 Computing diffs} *)

module Name_status = Name_status
module Num_status = Num_status
module Num_lines_in_diff = Num_lines_in_diff

val name_status
  :  < Trait.name_status ; .. > t
  -> repo_root:Repo_root.t
  -> changed:Name_status.Changed.t
  -> Name_status.t

val num_status
  :  < Trait.num_status ; .. > t
  -> repo_root:Repo_root.t
  -> changed:Num_status.Changed.t
  -> Num_status.t

(** {1 Manipulating the graph in memory} *)

module Log = Log
module Ref_kind = Ref_kind
module Refs = Refs
module Graph = Graph

val log : < Trait.log ; .. > t -> repo_root:Repo_root.t -> Log.t
val refs : < Trait.refs ; .. > t -> repo_root:Repo_root.t -> Refs.t
val graph : < Trait.log ; Trait.refs ; .. > t -> repo_root:Repo_root.t -> Graph.t

(** {1 Current branch & revision} *)

(** [current_branch] returns the branch currently checked out. This raises with
    an error message indicating ["Not currently on any branch."] when the repo
    is in a "detached-head" state. If you'd like to distinguish this specific
    case from other kinds of errors, see {!current_branch_opt}. *)
val current_branch
  :  < Trait.current_branch ; .. > t
  -> repo_root:Repo_root.t
  -> Branch_name.t

(** Returns [Some current_branch], if the repo is currently checked out at a
    given branch, or [None] when in "detached-head" state. This errors out on
    any other error conditions. *)
val current_branch_opt
  :  < Trait.current_branch ; .. > t
  -> repo_root:Repo_root.t
  -> Branch_name.t option

val current_revision : < Trait.current_revision ; .. > t -> repo_root:Repo_root.t -> Rev.t

(** {1 User config} *)

module Author = Author
module User_email = User_email
module User_handle = User_handle
module User_name = User_name

(** During tests in the GitHub environment we end up having issues if we do not
    set the user name and email. Also, we rather not do it globally. If this
    is never called, the current user config is used as usual by Git processes
    invocations. *)

val set_user_name
  :  < Trait.config ; .. > t
  -> repo_root:Repo_root.t
  -> user_name:User_name.t
  -> unit

val set_user_email
  :  < Trait.config ; .. > t
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
    be a [CLI] based backend, we might as well expose this. Use at your own
    risk/convenience. *)

module Git = Git

(** Note a non trivial behavior nuance depending on whether you are using this
    function using the raising or {{!non_raising_apis} non-raising API}. In the
    raising API, [f] is allowed to raise: [git] will catch any exception raised
    by [f], and rewrap it under a proper [E err] exception with added context.
    In the non-raising APIs, if [f] raises instead of returning an [Error], that
    exception would escape the function [git] and be raised by [git] as an
    uncaught exception. This would be considered a programming error.

    Some helpers are provided by the module {!module:Git} to help you build the
    [f] parameter. Non-raising modules are also included in the [Git] module
    dedicated to their respective result type (see for example
    [Volgo_base.Vcs.Git.Or_error]).

    The expectation is that you should be using the [Git] module of the API you
    are using to access the [git] function, and not mix and match.

    For example using the raising API::

    {[
      let git_status () : string =
        Vcs.git vcs ~repo_root ~args:[ "status" ] ~f:Vcs.Git.exit0_and_stdout
      ;;
    ]}

    Or the {{!non_raising_apis} non-raising API} (result):

    {[
      let git_status () : string Vcs.Result.t =
        Vcs.Result.git
          vcs
          ~repo_root
          ~args:[ "status" ]
          ~f:Vcs.Git.Result.exit0_and_stdout
      ;;
    ]} *)
val git
  :  ?env:string array
  -> ?run_in_subdir:Path_in_repo.t
  -> < Trait.git ; .. > t
  -> repo_root:Repo_root.t
  -> args:string list
  -> f:(Git.Output.t -> 'a)
  -> 'a

(** {1 Low level Mercurial cli}

    This part of Vcs provides direct access to the ["hg"] command line interface
    when operating in a Mercurial repository.

    This is similar to the low level access provided by {!val:git} and the same
    restrictions and advices apply. *)

module Hg = Hg

(** Simiar to {!val:git}, helpers are provided by the module {!module:Hg} to
    build the [f] parameter.

    The expectation is that you should be using the [Hg] module of the API you
    are using to access the [hg] function, and not mix and match.

    For example using the raising API:

    {[
      let hg_status () : string =
        Vcs.hg vcs ~repo_root ~args:[ "status" ] ~f:Vcs.Hg.exit0_and_stdout
      ;;
    ]}

    Or the {{!non_raising_apis} non-raising API} (result):

    {[
      let hg_status () : string Vcs.Result.t =
        Vcs.Result.hg vcs ~repo_root ~args:[ "status" ] ~f:Vcs.Hg.Result.exit0_and_stdout
      ;;
    ]} *)
val hg
  :  ?env:string array
  -> ?run_in_subdir:Path_in_repo.t
  -> < Trait.hg ; .. > t
  -> repo_root:Repo_root.t
  -> args:string list
  -> f:(Hg.Output.t -> 'a)
  -> 'a

(** {1:non_raising_apis Non-raising APIs}

    For convenience and to allow experimenting with different error handling
    strategies, [Vcs] exports non-raising APIs. The functions there return
    [Result.t]s instead of raising. *)

module Result = Vcs_result
module Rresult = Vcs_rresult
module Non_raising = Non_raising

module Private : sig
  (** This part of the interface is not stable. Things may break without notice
      and outside of the guidelines set by semver when upgrading to a new version
      of [Vcs]. This is used e.g. by tests or libraries with strong ties to
      [Vcs]. Do not use. *)

  module Bit_vector = Bit_vector
  module Import = Import
  module Int_table = Int_table
  module Process_output = Process_output
  module Ref_kind_table = Ref_kind_table
  module Rev_table = Rev_table
  module Validated_string = Validated_string

  (** [try_with f] runs [f] and wraps any exception it raises into an [Err.t]
      error. Because this catches all exceptions, including exceptions that may
      not be designed to be caught (such as [Stack_overflow], [Out_of_memory],
      etc.) we recommend that code be refactored overtime not to rely on this
      function. However, this is rather hard to do without assistance from the
      type checker, thus we currently rely on this function. TBD! *)
  val try_with : (unit -> 'a) -> ('a, Err.t) Stdlib.Result.t
end
