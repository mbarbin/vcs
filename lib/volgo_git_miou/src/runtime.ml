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

(*
   {[
     module Impl = Volgo_git_unix.Runtime

     type t = Impl.t

     let create () = Impl.create ()
     let load_file t ~path = Miou.call (fun () -> Impl.load_file t ~path) |> Miou.await_exn

     let save_file t ?perms () ~path ~file_contents =
       Miou.call (fun () -> Impl.save_file t ?perms () ~path ~file_contents)
       |> Miou.await_exn
     ;;

     let read_dir t ~dir = Miou.call (fun () -> Impl.read_dir t ~dir) |> Miou.await_exn

     let git ?env t ~cwd ~args ~f =
       Miou.call (fun () -> Impl.git ?env t ~cwd ~args ~f) |> Miou.await_exn
     ;;
   ]}
*)

open! Import

type t = unit

let create () = ()

let load_file_internal () ~path =
  Vcs.Private.try_with (fun () ->
    In_channel.with_open_bin (Absolute_path.to_string path) In_channel.input_all
    |> Vcs.File_contents.create)
;;

let save_file_internal
      (_ : t)
      ?(perms = 0o666)
      ()
      ~path
      ~(file_contents : Vcs.File_contents.t)
  =
  Vcs.Private.try_with (fun () ->
    let oc =
      open_out_gen
        [ Open_wronly; Open_creat; Open_trunc; Open_binary ]
        perms
        (Absolute_path.to_string path)
    in
    Fun.protect
      ~finally:(fun () -> close_out_noerr oc)
      (fun () -> Out_channel.output_string oc (file_contents :> string)))
;;

let read_dir_internal () ~dir =
  Vcs.Private.try_with (fun () ->
    let entries = Sys.readdir (Absolute_path.to_string dir) in
    Array.sort entries ~compare:String.compare;
    entries |> Array.map ~f:Fsegment.v |> Array.to_list)
;;

let with_cwd ~cwd ~f =
  let old_cwd = Unix.getcwd () in
  Fun.protect
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

exception Uncaught_user_exn of exn * Printexc.raw_backtrace

let git_unix ?env (_ : t) ~cwd ~args ~f =
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
        let stdout = In_channel.input_all stdout in
        stdout_r := stdout;
        let stderr = In_channel.input_all stderr in
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
        raise_notrace
          (Err.E
             (Err.create
                [ Err.sexp
                    [%sexp
                      "git process terminated abnormally"
                    , { exit_status : [ `Signaled of int | `Stopped of int ] }]
                ])) [@coverage off]
    in
    (* A note regarding the [raise_notrace] below. These cases are indeed
       exercised in the test suite, however bisect_ppx inserts a coverage point
       on the outer edge of the calls, defeating the coverage reports. Thus we
       have to manually disable coverage.

       Illustrating what the inserted unvisitable coverage point looks like:
       {[
         ___bisect_post_visit___ 36 (raise_notrace (Vcs.E err))
       ]}
    *)
    match f { Vcs.Git.Output.exit_code; stdout; stderr } with
    | Ok _ as ok -> ok
    | Error err -> raise_notrace (Err.E err) [@coverage off]
    | exception exn ->
      let bt = Printexc.get_raw_backtrace () in
      (raise_notrace (Uncaught_user_exn (exn, bt)) [@coverage off])
  with
  | Uncaught_user_exn (exn, bt) -> Printexc.raise_with_backtrace exn bt
  | exn ->
    let err = Err.of_exn exn in
    Error
      (Err.add_context
         err
         [ Err.sexp
             [%sexp
               { prog : string
               ; args : string list
               ; exit_status = (!exit_status_r : Exit_status.t)
               ; cwd : Absolute_path.t
               ; stdout = (Lines.create !stdout_r : Lines.t)
               ; stderr = (Lines.create !stderr_r : Lines.t)
               }]
         ])
;;

let load_file t ~path = Miou.call (fun () -> load_file_internal t ~path) |> Miou.await_exn

let save_file t ?perms () ~path ~file_contents =
  Miou.call (fun () -> save_file_internal t ?perms () ~path ~file_contents)
  |> Miou.await_exn
;;

let read_dir t ~dir = Miou.call (fun () -> read_dir_internal t ~dir) |> Miou.await_exn

let git ?env t ~cwd ~args ~f =
  Miou.call (fun () -> git_unix ?env t ~cwd ~args ~f) |> Miou.await_exn
;;
