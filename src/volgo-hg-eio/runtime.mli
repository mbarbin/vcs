(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

type t

include Volgo_hg_backend.Runtime.S with type t := t

val create : env:< fs : _ Eio.Path.t ; process_mgr : _ Eio.Process.mgr ; .. > -> t
