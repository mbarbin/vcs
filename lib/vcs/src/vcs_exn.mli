(*_******************************************************************************)
(*_  Vcs - a versatile OCaml library for Git interaction                        *)
(*_  Copyright (C) 2024 Mathieu Barbin <mathieu.barbin@gmail.com>               *)
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

(** Handling of exceptions in [Vcs].

    This module is used to handle exceptions that can occur when using the Vcs API. *)

(** [reraise_with_context err bt ~step] raises the original error in the form of
    an exception [E], with [step] added to [err]'s context. This is simply a
    convenient wrapper that combines [Printexc.raise_with_backtrace] and
    {!val:Err.add_context} under the hood.

    See the documentation of [Printexc.print_backtrace] for information about
    how to obtain an uncorrupted backtrace.

    Example:
    {[
      let doing_something_with_arg vcs ~arg =
        try Vcs.something vcs ~arg with
        | Vcs.E err ->
          let bt = Printexc.get_raw_backtrace () in
          Vcs.Exn.reraise_with_context
            err
            bt
            ~step:[%sexp "doing_something_with_arg", { arg : Arg.t }]
      ;;
    ]} *)
val reraise_with_context : Err.t -> Stdlib.Printexc.raw_backtrace -> step:Sexp.t -> _
