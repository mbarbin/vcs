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

(** Common process interfaces used in [Vcs].

    This file is configured in [dune] as an interface only file, so we don't need to
    duplicate the interfaces it contains into an [ml] file. *)

module type S = sig
  (** Helpers to wrap process outputs. *)

  type process_output
  type 'a result

  val exit0 : process_output -> unit result
  val exit0_and_stdout : process_output -> string result

  (** A convenient wrapper to write exhaustive match on a result conditioned by
      a list of accepted exit codes. If the exit code is not part of the
      accepted list, the function takes care of returning an error of the
      expected result type. *)
  val exit_code : process_output -> accept:(int * 'a) list -> 'a result
end
