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

module T = struct
  [@@@coverage off]

  type t =
    { exit_code : int
    ; stdout : string
    ; stderr : string
    }
  [@@deriving_inline sexp_of]

  let sexp_of_t =
    (fun { exit_code = exit_code__002_; stdout = stdout__004_; stderr = stderr__006_ } ->
       let bnds__001_ = ([] : _ Stdlib.List.t) in
       let bnds__001_ =
         let arg__007_ = sexp_of_string stderr__006_ in
         (Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "stderr"; arg__007_ ] :: bnds__001_
          : _ Stdlib.List.t)
       in
       let bnds__001_ =
         let arg__005_ = sexp_of_string stdout__004_ in
         (Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "stdout"; arg__005_ ] :: bnds__001_
          : _ Stdlib.List.t)
       in
       let bnds__001_ =
         let arg__003_ = sexp_of_int exit_code__002_ in
         (Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "exit_code"; arg__003_ ] :: bnds__001_
          : _ Stdlib.List.t)
       in
       Sexplib0.Sexp.List bnds__001_
     : t -> Sexplib0.Sexp.t)
  ;;

  [@@@deriving.end]
end

include T

module Private = struct
  let of_process_output t = t
end
