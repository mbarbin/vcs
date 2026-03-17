(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module T = struct
  module T0 = struct
    type t = Vcs.Platform.t =
      | Bitbucket
      | Codeberg
      | GitHub
      | GitLab
      | Sourcehut
    [@@deriving hash]
  end

  include (Vcs.Platform : module type of Vcs.Platform with type t := T0.t)
  include T0
end

include T
include Comparable.Make (T)
