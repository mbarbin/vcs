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
  { fs : Eio.Fs.dir_ty Eio.Path.t
  ; process_mgr : [ `Generic ] Eio.Process.mgr_ty Eio.Process.mgr
  }

let create ~env =
  { fs = (Eio.Stdenv.fs env :> Eio.Fs.dir_ty Eio.Path.t)
  ; process_mgr =
      (Eio.Stdenv.process_mgr env :> [ `Generic ] Eio.Process.mgr_ty Eio.Process.mgr)
  }
;;

let load_file t ~path =
  let path = Eio.Path.(t.fs / Absolute_path.to_string path) in
  Or_error.try_with (fun () -> Vcs.File_contents.create (Eio.Path.load path))
;;

let save_file ?(perms = 0o666) t ~path ~(file_contents : Vcs.File_contents.t) =
  let path = Eio.Path.(t.fs / Absolute_path.to_string path) in
  Or_error.try_with (fun () ->
    Eio.Path.save ~create:(`Or_truncate perms) path (file_contents :> string))
;;

let git ?env t ~cwd ~args ~f =
  Eio_process.run
    ~process_mgr:t.process_mgr
    ~cwd:Eio.Path.(t.fs / Absolute_path.to_string cwd)
    ?env
    ~prog:"git"
    ~args
    ()
    ~f:(fun { Eio_process.Output.stdout; stderr; exit_status } ->
      match exit_status with
      | `Exited exit_code -> f { Vcs.Git.Output.exit_code; stdout; stderr }
      | `Signaled signal ->
        Or_error.error_s
          [%sexp "process exited abnormally", { signal : int }] [@coverage off])
;;
