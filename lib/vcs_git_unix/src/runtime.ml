(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
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

let git_executable_basename = "git"

module Found_executable = struct
  type t =
    { filename : string
    ; path : string
    }
end

type t = { git_executable : Found_executable.t option }

let find_executable ~path =
  let rec loop = function
    | [] -> None
    | path :: rest ->
      let fn = Filename.concat path git_executable_basename in
      if Sys.file_exists fn then Some fn else loop rest
  in
  loop (String.split path ~on:':')
;;

let create () =
  let git_executable =
    match Stdlib.Sys.getenv_opt "PATH" with
    | None -> None [@coverage off]
    | Some path ->
      (match find_executable ~path with
       | None -> None
       | Some filename -> Some { Found_executable.filename; path })
  in
  { git_executable }
;;

let load_file (_ : t) ~path =
  Vcs.Exn.Private.try_with (fun () ->
    In_channel.with_open_bin (Absolute_path.to_string path) In_channel.input_all
    |> Vcs.File_contents.create)
;;

let save_file (_ : t) ?(perms = 0o666) () ~path ~(file_contents : Vcs.File_contents.t) =
  Vcs.Exn.Private.try_with (fun () ->
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

let read_dir (_ : t) ~dir =
  Vcs.Exn.Private.try_with (fun () ->
    let entries = Sys.readdir (Absolute_path.to_string dir) in
    Array.sort entries ~compare:String.compare;
    entries |> Array.map ~f:Fsegment.v |> Array.to_list)
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

let git ?env t ~cwd ~args ~f =
  let unix_env =
    match env with
    | None -> None
    | Some env ->
      (let env =
         Array.map
           ~f:(fun var ->
             match String.lsplit2 var ~on:'=' with
             | None -> var, ""
             | Some var -> var)
           env
         |> Array.to_list
       in
       Some env)
      [@coverage off]
  in
  let prog =
    match t.git_executable with
    | None -> git_executable_basename
    | Some { filename; path } ->
      (match unix_env with
       | None -> filename
       | Some bindings ->
         (match List.find bindings ~f:(fun (var, _) -> String.equal var "PATH") with
          | None -> filename
          | Some (_, path_override) ->
            if String.equal path path_override then filename else git_executable_basename))
  in
  let process =
    Shexp_process.capture
      [ Stderr ]
      (Shexp_process.capture [ Stdout ] (Shexp_process.call_exit_code (prog :: args)))
  in
  let exit_status_r : Exit_status.t ref = ref `Unknown in
  let stdout_r = ref "" in
  let stderr_r = ref "" in
  try
    let context =
      Shexp_process.Context.create ~cwd:(Path (Absolute_path.to_string cwd)) ?unix_env ()
    in
    let (exit_code, stdout), stderr = Shexp_process.eval ~context process in
    exit_status_r := `Exited exit_code;
    stdout_r := stdout;
    stderr_r := stderr;
    Shexp_process.Context.dispose context;
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
    | Error err -> raise_notrace (Vcs.E err) [@coverage off]
    | exception exn ->
      let bt = Printexc.get_raw_backtrace () in
      (raise_notrace (Uncaught_user_exn (exn, bt)) [@coverage off])
  with
  | Uncaught_user_exn (exn, bt) -> Printexc.raise_with_backtrace exn bt
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

module Private = struct
  let find_executable = find_executable
end
