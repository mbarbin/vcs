(*******************************************************************************)
(*  Volgo - a Versatile OCaml Library for Git Operations                       *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
(*                                                                             *)
(*  This file is part of Volgo.                                                *)
(*                                                                             *)
(*  Volgo is free software; you can redistribute it and/or modify it under     *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Volgo is distributed in the hope that it will be useful, but WITHOUT ANY   *)
(*  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*  the file `NOTICE.md` at the root of this repository for more details.      *)
(*                                                                             *)
(*  You should have received a copy of the GNU Lesser General Public License   *)
(*  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*******************************************************************************)

module Protocol = struct
  module T0 = struct
    type t = Vcs.Url.Protocol.t =
      | Ssh
      | Https
    [@@deriving hash]
  end

  include (Vcs.Url.Protocol : module type of Vcs.Url.Protocol with type t := T0.t)
  include T0
end

module T0 = struct
  type t = Vcs.Url.t =
    { platform : Platform.t
    ; protocol : Protocol.t
    ; user_handle : User_handle.t
    ; repo_name : Repo_name.t
    }
  [@@deriving hash]
end

include (
  Vcs.Url : module type of Vcs.Url with type t := T0.t and module Protocol := Protocol)

include T0
