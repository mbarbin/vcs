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

[@@@ocaml.alert "-deprecated"]

type t = Err.t
[@@ocaml.deprecated "[since 2025-05] Use [Err.t]. Hint: Run [ocamlmig migrate]"]
[@@migrate { repl = Err.t; libraries = [ "pplumbing.err" ] }]

(** This is deprecated - use [Err.sexp_of_t] instead. *)
val sexp_of_t : t -> Sexp.t
[@@ocaml.deprecated "[since 2025-05] Use [Err.sexp_of_t]. Hint: Run [ocamlmig migrate]"]
[@@migrate { repl = Err.sexp_of_t; libraries = [ "pplumbing.err" ] }]

(** This is deprecated - use [Err.to_string_hum] instead. *)
val to_string_hum : t -> string
[@@ocaml.deprecated
  "[since 2025-05] Use [Err.to_string_hum]. Hint: Run [ocamlmig migrate]"]
[@@migrate { repl = Err.to_string_hum; libraries = [ "pplumbing.err" ] }]

(** This is deprecated - use [Err.create] instead. *)
val error_string : string -> t
[@@ocaml.deprecated "[since 2025-05] Use [Err.create]. Hint: Run [ocamlmig migrate]"]
[@@migrate
  { repl = (fun str -> Err.create [ Pp.text str ])
  ; libraries = [ "pp"; "pplumbing.err" ]
  }]

(** This is deprecated - use [Err.create] instead. *)
val create_s : Sexp.t -> t
[@@ocaml.deprecated "[since 2025-05] Use [Err.create]. Hint: Run [ocamlmig migrate]"]
[@@migrate
  { repl = (fun sexp -> Err.create [ Err.sexp sexp ]); libraries = [ "pplumbing.err" ] }]

(** This is deprecated - use [Err.of_exn] instead. *)
val of_exn : exn -> t
[@@ocaml.deprecated "[since 2025-05] Use [Err.of_exn]. Hint: Run [ocamlmig migrate]"]
[@@migrate { repl = Err.of_exn; libraries = [ "pplumbing.err" ] }]

(** This is deprecated - use [Err.add_context] instead. *)
val add_context : t -> step:Sexp.t -> t
[@@ocaml.deprecated "[since 2025-05] Use [Err.add_context]. Hint: Run [ocamlmig migrate]"]
[@@migrate
  { repl = (fun t ~step -> Err.add_context t [ (Err.sexp step [@commutes]) ])
  ; libraries = [ "pplumbing.err" ]
  }]

(** This is deprecated - use [Err.add_context] instead. *)
val init : Sexp.t -> step:Sexp.t -> t
[@@ocaml.deprecated "[since 2025-05] Use [Err.add_context]. Hint: Run [ocamlmig migrate]"]
[@@migrate
  { repl =
      (fun error ~step ->
        Err.add_context
          (Err.create [ (Err.sexp error [@commutes]) ] [@commutes])
          [ (Err.sexp step [@commutes]) ])
  ; libraries = [ "pplumbing.err" ]
  }]
