(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type t = Volgo_git_backend.Trait.t Vcs.t

module Impl = struct
  include Runtime
  include Volgo_git_backend.Make (Runtime)
end

let create_class () = new Impl.c (Impl.create ())
let create () = Vcs.create (create_class ())

module Runtime = Runtime
module Make_runtime = Make_runtime
