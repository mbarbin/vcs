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

(** An [Vcs] API in the style of
    {{:https://erratique.ch/software/rresult/doc/Rresult/index.html#usage} Rresult}. *)

type err = [ `Vcs of Err.t ]
type 'a result = ('a, err) Result.t

(** {1 Utils}

    This part exposes the functions prescribed by the
    {{:https://erratique.ch/software/rresult/doc/Rresult/index.html#usage} Rresult}
    usage design guidelines. *)

val pp_error : Stdlib.Format.formatter -> [ `Vcs of Err.t ] -> unit
val open_error : 'a result -> ('a, [> `Vcs of Err.t ]) Result.t
val error_to_msg : 'a result -> ('a, [ `Msg of string ]) Result.t

(** {1 Non raising API}

    The individual functions are documented the {!module:Vcs} module. *)

include Non_raising.S with type 'a t := 'a Vcs0.t and type 'a result := 'a result
