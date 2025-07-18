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
