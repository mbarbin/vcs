(*_******************************************************************************)
(*_  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*_  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
(*_                                                                             *)
(*_  This file is part of Vcs.                                                  *)
(*_                                                                             *)
(*_  Vcs is free software; you can redistribute it and/or modify it under       *)
(*_  the terms of the GNU Lesser General Public License as published by the     *)
(*_  Free Software Foundation either version 3 of the License, or any later     *)
(*_  version, with the LGPL-3.0 Linking Exception.                              *)
(*_                                                                             *)
(*_  Vcs is distributed in the hope that it will be useful, but WITHOUT ANY     *)
(*_  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*_  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*_  the file `NOTICE.md` at the root of this repository for more details.      *)
(*_                                                                             *)
(*_  You should have received a copy of the GNU Lesser General Public License   *)
(*_  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*_  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*_******************************************************************************)

(** Note that this entire module is scheduled for deprecation. Vcs has migrated
    to using [Err.t] from the [pplumbing.err] package.

    We have prepared [ocamlmig] annotations in this module to help migrating
    existing clients, and we plan on adding deprecation annotations in a future
    release. *)

(** This is deprecated - use [Err.reraise_with_context] instead. *)
val reraise_with_context : Err.t -> Printexc.raw_backtrace -> step:Sexp.t -> _
[@@ocaml.deprecated
  "[since 2025-05] Use [Err.reraise_with_context]. Hint: Run [ocamlmig migrate]"]
[@@migrate
  { repl =
      (fun err bt ~step ->
        Err.reraise_with_context err bt [ (Err.sexp step [@commutes]) ])
  ; libraries = [ "pplumbing.err" ]
  }]
