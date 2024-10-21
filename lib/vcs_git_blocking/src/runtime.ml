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

open! Import

type t = unit

let create () = ()

let load_file () ~path =
  Vcs.Exn.Private.try_with (fun () ->
    Stdlib.In_channel.with_open_bin
      (Absolute_path.to_string path)
      Stdlib.In_channel.input_all
    |> Vcs.File_contents.create)
;;

let save_file ?(perms = 0o666) () ~path ~(file_contents : Vcs.File_contents.t) =
  Vcs.Exn.Private.try_with (fun () ->
    let oc =
      Stdlib.open_out_gen
        [ Open_wronly; Open_creat; Open_trunc; Open_binary ]
        perms
        (Absolute_path.to_string path)
    in
    Stdlib.Fun.protect
      ~finally:(fun () -> Stdlib.close_out_noerr oc)
      (fun () -> Stdlib.Out_channel.output_string oc (file_contents :> string)))
;;

let read_dir () ~dir =
  Vcs.Exn.Private.try_with (fun () ->
    let entries = Stdlib.Sys.readdir (Absolute_path.to_string dir) in
    Array.sort entries ~compare:String.compare;
    entries |> Array.map ~f:Fsegment.v |> Array.to_list)
;;

let with_cwd ~cwd ~f =
  let old_cwd = Unix.getcwd () in
  Stdlib.Fun.protect
    ~finally:(fun () -> Unix.chdir old_cwd)
    (fun () ->
      Unix.chdir (Absolute_path.to_string cwd);
      f ())
;;

module Exit_status = struct
  [@@@coverage off]

  type t =
    [ `Exited of int
    | `Signaled of int
    | `Stopped of int
    | `Unknown
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

exception Uncaught_user_exn of exn * Stdlib.Printexc.raw_backtrace

let git ?env () ~cwd ~args ~f =
  let prog = "git" in
  let env =
    match env with
    | None -> Unix.environment ()
    | Some env -> env [@coverage off]
  in
  let exit_status_r : Exit_status.t ref = ref `Unknown in
  let stdout_r = ref "" in
  let stderr_r = ref "" in
  try
    let process_status, stdout, stderr =
      with_cwd ~cwd ~f:(fun () ->
        let ((stdout, _, stderr) as process_full) =
          Unix.open_process_args_full prog (Array.of_list (prog :: args)) env
        in
        let stdout = Stdlib.In_channel.input_all stdout in
        stdout_r := stdout;
        let stderr = Stdlib.In_channel.input_all stderr in
        stderr_r := stderr;
        let process_status = Unix.close_process_full process_full in
        process_status, stdout, stderr)
    in
    let exit_status =
      match process_status with
      | Unix.WEXITED n -> `Exited n
      | Unix.WSIGNALED n -> `Signaled n [@coverage off]
      | Unix.WSTOPPED n -> `Stopped n [@coverage off]
    in
    exit_status_r := exit_status;
    let exit_code =
      match exit_status with
      | `Exited n -> n
      | (`Signaled _ | `Stopped _) as exit_status ->
        Stdlib.raise_notrace
          (Vcs.E
             (Vcs.Err.create_s
                [%sexp
                  "git process terminated abnormally"
                  , { exit_status : [ `Signaled of int | `Stopped of int ] }]))
        [@coverage off]
    in
    match f { Vcs.Git.Output.exit_code; stdout; stderr } with
    | Ok _ as ok -> ok
    | Error err -> Stdlib.raise_notrace (Vcs.E err)
    | exception exn ->
      let bt = Stdlib.Printexc.get_raw_backtrace () in
      Stdlib.raise_notrace (Uncaught_user_exn (exn, bt))
  with
  | Uncaught_user_exn (exn, bt) -> Stdlib.Printexc.raise_with_backtrace exn bt
  | exn ->
    let err =
      match exn with
      | Vcs.E err -> err
      | _ -> Vcs.Err.of_exn exn
    in
    Error
      (Vcs.Err.add_context
         err
         ~step:
           [%sexp
             { prog : string
             ; args : string list
             ; exit_status = (!exit_status_r : Exit_status.t)
             ; cwd : Absolute_path.t
             ; stdout = (Lines.create !stdout_r : Lines.t)
             ; stderr = (Lines.create !stderr_r : Lines.t)
             }])
;;
