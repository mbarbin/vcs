(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

module Vcs_kind : sig
  type t = Vcs.Platform_repo.Vcs_kind.t =
    | Git
    | Hg
  [@@deriving hash]

  include module type of Vcs.Platform_repo.Vcs_kind with type t := t
end

module Protocol : sig
  type t = Vcs.Platform_repo.Protocol.t =
    | Ssh
    | Https
  [@@deriving hash]

  include module type of Vcs.Platform_repo.Protocol with type t := t
end

module Url : sig
  type t = Vcs.Platform_repo.Url.t =
    { platform : Platform.t
    ; vcs_kind : Vcs_kind.t
    ; user_handle : User_handle.t
    ; repo_name : Repo_name.t
    ; protocol : Protocol.t
    }
  [@@deriving hash]

  include module type of Vcs.Platform_repo.Url with type t := t
end

type t = Vcs.Platform_repo.t =
  { platform : Platform.t
  ; vcs_kind : Vcs_kind.t
  ; user_handle : User_handle.t
  ; repo_name : Repo_name.t
  }
[@@deriving hash]

include
  module type of Vcs.Platform_repo
  with type t := t
   and module Protocol := Protocol
   and module Url := Url
   and module Vcs_kind := Vcs_kind
