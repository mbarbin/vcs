(*******************************************************************************)
(*  Vcs - a versatile OCaml library for Git interaction                        *)
(*  Copyright (C) 2024 Mathieu Barbin <mathieu.barbin@gmail.com>               *)
(*                                                                             *)
(*  This file is part of Vcs.                                                  *)
(*                                                                             *)
(*  Vcs is free software; you can redistribute it and/or modify it under       *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Vcs is distributed in the hope that it will be useful, but WITHOUT ANY     *)
(*  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*  the file `NOTICE.md` at the root of this repository for more details.      *)
(*                                                                             *)
(*  You should have received a copy of the GNU Lesser General Public License   *)
(*  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*******************************************************************************)

type t =
  { of_mock : Rev.t Hashtbl.M(Rev).t
  ; to_mock : Rev.t Hashtbl.M(Rev).t
  ; mock_rev_gen : Mock_rev_gen.t
  }

let create () =
  let mock_rev_gen = Mock_rev_gen.create ~name:"mock-revs" in
  { of_mock = Hashtbl.create (module Rev)
  ; to_mock = Hashtbl.create (module Rev)
  ; mock_rev_gen
  }
;;

let next t = Mock_rev_gen.next t.mock_rev_gen

let add_exn t ~rev ~mock_rev =
  Hashtbl.add_exn t.to_mock ~key:rev ~data:mock_rev;
  Hashtbl.add_exn t.of_mock ~key:mock_rev ~data:rev
;;

let to_mock t ~rev =
  match Hashtbl.find t.to_mock rev with
  | Some rev -> rev
  | None ->
    let mock_rev = next t in
    add_exn t ~rev ~mock_rev;
    mock_rev
;;

let of_mock t ~mock_rev = Hashtbl.find t.of_mock mock_rev
