(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** A type to uniquely identify a repository hosted on a platform. *)

module Vcs_kind : sig
  (** Some platform support hosting Mercurial repositories. We use this type to
      distinguish.

      Note that some combinations of values are meaningless. For example, there
      are no Mercurial repository on GitHub. *)

  type t =
    | Git
    | Hg

  include Container_key.S with type t := t

  val all : t list
end

type t =
  { platform : Platform.t
  ; vcs_kind : Vcs_kind.t
  ; user_handle : User_handle.t
  ; repo_name : Repo_name.t
  }

include Container_key.S with type t := t

module Protocol : sig
  type t =
    | Ssh
    | Https

  include Container_key.S with type t := t

  val all : t list
end

module Ssh_syntax : sig
  (** There are two style of SSH addresses used by popular platforms.

      - [Scp_like]: The traditional "scp-like" syntax, e.g.
        [git@github.com:user/repo.git].

      - [Url_style]: The "ssh://" URL style, e.g.
        [ssh://git@codeberg.org/user/repo.git].

      This types allows to distinguish between the two and is used as parameter
      by functions that generate the concrete syntax for a url to a platform
      repo, to be used e.g. when cloning, or configuring a remote. *)

  type t =
    | Scp_like
    | Url_style

  include Container_key.S with type t := t

  val all : t list

  (** Each platform has a default behavior in that they have a style of ssh url
      they use when displaying the addresses of the repos. Note that they can
      probably handle all styles when parsing the url.

      Beware, this may probably change overtime as platforms evolve. *)
  val used_by_default_on_platform : platform:Platform.t -> t
end

module Url : sig
  (** A [Url] for a platform repo that is suitable to perform vcs operations,
      such as [clone]. *)

  type t =
    { platform : Platform.t
    ; vcs_kind : Vcs_kind.t
    ; user_handle : User_handle.t
    ; repo_name : Repo_name.t
    ; protocol : Protocol.t
    }

  include Container_key.S with type t := t

  (** Create a complete string suitable for use with git commands, such as
      remote add, clone, etc. *)
  val to_string : t -> ssh_syntax:Ssh_syntax.t -> string

  (** This produces the url in a normalized form where ssh addresses are written
      using the [Url_style] syntax. Most vcs clients should be compatible with
      this.

      If you are looking for some kind of systematic representation, you may
      probably prefer this over {!to_platform_string}. *)
  val to_url_string : t -> string

  (** This is the same as [to_string] where the [ssh_syntax] parameter is
      determined by {!Ssh_syntax.used_by_default_on_platform}. *)
  val to_platform_string : t -> string

  (** Parse a string into a url. This is able to parse both ssh syntaxes. *)
  val of_string : string -> (t, [ `Msg of string ]) Result.t

  (** A wrapper for [of_string] that raises [Invalid_argument] on invalid input. *)
  val v : string -> t
end

val to_url : t -> protocol:Protocol.t -> Url.t
val of_url : Url.t -> t
