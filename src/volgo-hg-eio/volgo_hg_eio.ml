(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type t = Volgo_hg_backend.Trait.t Vcs.t

module Impl = struct
  include Runtime
  include Volgo_hg_backend.Make (Runtime)
end

let create_class ~env = new Impl.c (Impl.create ~env)
let create ~env = Vcs.create (create_class ~env)

module Runtime = Runtime
