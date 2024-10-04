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

let read_dir t ~dir =
  let dir = Eio.Path.(t.fs / Absolute_path.to_string dir) in
  Or_error.try_with (fun () -> Eio.Path.read_dir dir |> List.map ~f:Fpart.v)
;;

(* The modules [Exit_status], [Lines] and the function [git] below are derived
   from the [Eio_process] project version [0.0.4] which is released under MIT
   and may be found at [https://github.com/mbarbin/eio-process].

   The changes we made to the code are:

   - We removed the ability to parse the output of the process as a sexp. We
     don't expect a git process to use the sexp format for its output (stdout
     and stderr alike).

   - We treat a signaled exit status as an error.

   - The [git] function was adapted from [Eio_process.run], inlining the part
     specific to git directly into the new function. We expect that the [git]
     function may be further specialized in the future to fit the requirement of
     the project.

   See Eio_process's LICENSE below:

   ----------------------------------------------------------------------------

   MIT License

   Copyright (c) 2023 Mathieu Barbin

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE. *)

module Exit_status = struct
  [@@@coverage off]

  type t =
    [ `Exited of int
    | `Signaled of int
    ]
  [@@deriving sexp_of]
end

module Lines = struct
  type t = string list

  let sexp_of_t (t : t) =
    match t with
    | [] -> [%sexp ""]
    | [ hd ] -> [%sexp (hd : string)]
    | _ :: _ :: _ as lines -> [%sexp (lines : string list)]
  ;;

  let create string : t = String.split_lines string
end

exception User_error of Error.t

let git ?env t ~cwd ~args ~f =
  let cwd = Eio.Path.(t.fs / Absolute_path.to_string cwd) in
  let prog = "git" in
  Eio.Switch.run
  @@ fun sw ->
  let r, w = Eio.Process.pipe t.process_mgr ~sw in
  let re, we = Eio.Process.pipe t.process_mgr ~sw in
  let exit_status_r : [ Exit_status.t | `Unknown ] ref = ref `Unknown in
  let stdout_r = ref "" in
  let stderr_r = ref "" in
  try
    let child =
      Eio.Process.spawn
        ~sw
        t.process_mgr
        ~cwd
        ?stdin:None
        ~stdout:w
        ~stderr:we
        ?env
        ?executable:None
        (prog :: args)
    in
    Eio.Flow.close w;
    Eio.Flow.close we;
    let stdout = Eio.Buf_read.parse_exn Eio.Buf_read.take_all r ~max_size:Int.max_value in
    stdout_r := stdout;
    let stderr =
      Eio.Buf_read.parse_exn Eio.Buf_read.take_all re ~max_size:Int.max_value
    in
    stderr_r := stderr;
    Eio.Flow.close r;
    let exit_status = Eio.Process.await child in
    exit_status_r := (exit_status :> [ Exit_status.t | `Unknown ]);
    match exit_status with
    | `Signaled signal ->
      raise
        (User_error
           (Error.create_s
              [%sexp "process exited abnormally", { signal : int }] [@coverage off]))
      [@coverage off]
    | `Exited exit_code ->
      (match f { Vcs.Git.Output.exit_code; stdout; stderr } with
       | Ok _ as ok -> ok
       | Error err -> raise (User_error err))
  with
  | (Eio.Exn.Io _ | User_error _) as exn ->
    let error =
      match exn with
      | Eio.Exn.Io _ -> Error.of_exn exn
      | User_error error -> error
      | _ -> assert false
    in
    Or_error.error_s
      [%sexp
        { prog : string
        ; args : string list
        ; exit_status = (!exit_status_r : [ Exit_status.t | `Unknown ])
        ; cwd = (snd cwd : string)
        ; stdout = (Lines.create !stdout_r : Lines.t)
        ; stderr = (Lines.create !stderr_r : Lines.t)
        ; error : Error.t
        }]
;;
