(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Vcs_kind = struct
  module T0 = struct
    type t = Vcs.Platform_repo.Vcs_kind.t =
      | Git
      | Hg
    [@@deriving hash]
  end

  include (
    Vcs.Platform_repo.Vcs_kind :
      module type of Vcs.Platform_repo.Vcs_kind with type t := T0.t)

  include T0
end

module Protocol = struct
  module T0 = struct
    type t = Vcs.Platform_repo.Protocol.t =
      | Ssh
      | Https
    [@@deriving hash]
  end

  include (
    Vcs.Platform_repo.Protocol :
      module type of Vcs.Platform_repo.Protocol with type t := T0.t)

  include T0
end

module Url = struct
  module T0 = struct
    type t = Vcs.Platform_repo.Url.t =
      { platform : Platform.t
      ; vcs_kind : Vcs_kind.t
      ; user_handle : User_handle.t
      ; repo_name : Repo_name.t
      ; protocol : Protocol.t
      }
    [@@deriving hash]
  end

  include (
    Vcs.Platform_repo.Url : module type of Vcs.Platform_repo.Url with type t := T0.t)

  include T0
end

module T0 = struct
  type t = Vcs.Platform_repo.t =
    { platform : Platform.t
    ; vcs_kind : Vcs_kind.t
    ; user_handle : User_handle.t
    ; repo_name : Repo_name.t
    }
  [@@deriving hash]
end

include (
  Vcs.Platform_repo :
    module type of Vcs.Platform_repo
    with type t := T0.t
     and module Protocol := Protocol
     and module Url := Url
     and module Vcs_kind := Vcs_kind)

include T0
