(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
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

module Impl = Volgo_git_unix.Runtime

type t = Impl.t

let create () = Impl.create ()
let load_file t ~path = Miou.call (fun () -> Impl.load_file t ~path) |> Miou.await_exn

let save_file t ?perms () ~path ~file_contents =
  Miou.call (fun () -> Impl.save_file t ?perms () ~path ~file_contents) |> Miou.await_exn
;;

let read_dir t ~dir = Miou.call (fun () -> Impl.read_dir t ~dir) |> Miou.await_exn

let git ?env t ~cwd ~args ~f =
  Miou.call (fun () -> Impl.git ?env t ~cwd ~args ~f) |> Miou.await_exn
;;
