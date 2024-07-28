(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Interaction                        *)
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

type t = unit

let create () = ()

let load_file () ~path =
  Or_error.try_with (fun () ->
    Stdlib.In_channel.with_open_bin
      (Absolute_path.to_string path)
      Stdlib.In_channel.input_all
    |> Vcs.File_contents.create)
;;

let save_file ?(perms = 0o666) () ~path ~(file_contents : Vcs.File_contents.t) =
  Or_error.try_with (fun () ->
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

let with_cwd ~cwd ~f =
  let old_cwd = Unix.getcwd () in
  Stdlib.Fun.protect
    ~finally:(fun () -> Unix.chdir old_cwd)
    (fun () ->
      Unix.chdir (Absolute_path.to_string cwd);
      f ())
;;

exception User_error of Error.t

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
  type t = Lines of string list

  let sexp_of_t t =
    match t with
    | Lines [] -> [%sexp ""]
    | Lines lines -> [%sexp (lines : string list)]
  ;;

  let create string = Lines (String.split_lines string)
end

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
        raise
          (User_error
             (Error.create_s
                [%sexp
                  "git process terminated abnormally"
                  , { exit_status : [ `Signaled of int | `Stopped of int ] }]))
        [@coverage off]
    in
    match f { Vcs.Git.Output.exit_code; stdout; stderr } with
    | Ok _ as ok -> ok
    | Error err -> raise (User_error err)
  with
  | exn ->
    let error =
      match exn with
      | User_error error -> error
      | exn -> Error.of_exn exn
    in
    Or_error.error_s
      [%sexp
        { prog : string
        ; args : string list
        ; exit_status = (!exit_status_r : Exit_status.t)
        ; cwd : Absolute_path.t
        ; stdout = (Lines.create !stdout_r : Lines.t)
        ; stderr = (Lines.create !stderr_r : Lines.t)
        ; error : Error.t
        }]
;;
