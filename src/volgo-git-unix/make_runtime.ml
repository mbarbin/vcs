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

module Unix = UnixLabels

module type S = sig
  type t

  val create : unit -> t

  (** {1 I/O} *)

  include Vcs.Trait.File_system.S with type t := t

  (** {1 Running the git command line} *)

  type process_output

  val vcs_cli
    :  ?env:string array
    -> t
    -> cwd:Absolute_path.t
    -> args:string list
    -> f:(process_output -> ('a, Err.t) Result.t)
    -> ('a, Err.t) Result.t
end

module type M = sig
  val executable_basename : string

  module Output : sig
    type t

    module Private : sig
      val of_process_output : Vcs.Private.Process_output.t -> t
    end
  end
end

module Found_executable = struct
  type t =
    { filename : string
    ; path : string
    }
end

let find_executable ~path ~executable_basename =
  let rec loop = function
    | [] -> None
    | path :: rest ->
      let fn = Filename.concat path executable_basename in
      if Sys.file_exists fn then Some fn else loop rest
  in
  loop (String.split path ~on:':')
;;

type t =
  { executable_basename : string
  ; executable : Found_executable.t option
  }

let load_file (_ : t) ~path =
  Vcs.Private.try_with (fun () ->
    In_channel.with_open_bin (Absolute_path.to_string path) In_channel.input_all
    |> Vcs.File_contents.create)
;;

let save_file (_ : t) ?(perms = 0o666) () ~path ~(file_contents : Vcs.File_contents.t) =
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

let read_dir (_ : t) ~dir =
  Vcs.Private.try_with (fun () ->
    let entries = Sys.readdir (Absolute_path.to_string dir) in
    Array.sort entries ~compare:String.compare;
    entries |> Array.to_list_mapi ~f:(fun _ f -> Fsegment.v f))
;;

module Exit_status = struct
  [@@@coverage off]

  type t =
    [ `Exited of int
    | `Signaled of int
    | `Stopped of int
    | `Unknown
    ]

  let to_dyn = function
    | `Exited n -> Dyn.Variant ("Exited", [ Dyn.int n ])
    | `Signaled n -> Dyn.Variant ("Signaled", [ Dyn.int n ])
    | `Stopped n -> Dyn.Variant ("Stopped", [ Dyn.int n ])
    | `Unknown -> Dyn.Variant ("Unknown", [])
  ;;

  let sexp_of_t t = Dyn.to_sexp (to_dyn t)
end

module Lines = struct
  type t = string list

  let sexp_of_t (t : t) =
    match t with
    | [] -> Sexp.Atom ""
    | [ hd ] -> Sexp.Atom (hd : string)
    | _ :: _ :: _ as lines -> Sexp.List (List.map lines ~f:(fun line -> Sexp.Atom line))
  ;;

  let create string : t = String.split_lines string
end

exception Uncaught_user_exn of exn * Printexc.raw_backtrace

let create ~executable_basename =
  let executable =
    match Sys.getenv_opt "PATH" with
    | None -> None [@coverage off]
    | Some path ->
      (match find_executable ~path ~executable_basename with
       | None -> None
       | Some filename -> Some { Found_executable.filename; path })
  in
  { executable_basename; executable }
;;

let rec waitpid_non_intr pid =
  try Unix.waitpid ~mode:[] pid with
  | Unix.Unix_error (EINTR, _, _) -> waitpid_non_intr pid [@coverage off]
;;

let read_all_from_fd fd =
  let out = In_channel.input_all (Unix.in_channel_of_descr fd) in
  Unix.close fd;
  out
;;

let vcs_cli ~of_process_output ?env t ~cwd ~args ~f =
  let env = Option.map env ~f:Array.to_list in
  let executable_basename = t.executable_basename in
  let prog =
    match t.executable with
    | None -> executable_basename
    | Some { filename; path } ->
      (match env with
       | None -> filename
       | Some bindings ->
         (match
            List.find_map bindings ~f:(fun var -> String.chop_prefix var ~prefix:"PATH=")
          with
          | None -> filename
          | Some path_override ->
            if String.equal path path_override
            then filename
            else (
              match find_executable ~path:path_override ~executable_basename with
              | None -> executable_basename
              | Some filename -> filename)))
  in
  let exit_status_r : Exit_status.t ref = ref `Unknown in
  let stdout_r = ref "" in
  let stderr_r = ref "" in
  try
    let stdin_reader, stdin_writer = Spawn.safe_pipe () in
    let stdout_reader, stdout_writer = Spawn.safe_pipe () in
    let stderr_reader, stderr_writer = Spawn.safe_pipe () in
    let pid =
      Spawn.spawn
        ?env:(env |> Option.map ~f:Spawn.Env.of_list)
        ~cwd:(Path (Absolute_path.to_string cwd))
        ~prog
        ~argv:(executable_basename :: args)
        ~stdin:stdin_reader
        ~stdout:stdout_writer
        ~stderr:stderr_writer
        ()
    in
    Unix.close stdin_reader;
    Unix.close stdin_writer;
    Unix.close stdout_writer;
    Unix.close stderr_writer;
    let stdout = read_all_from_fd stdout_reader in
    let stderr = read_all_from_fd stderr_reader in
    let pid', process_status = waitpid_non_intr pid in
    assert (pid = pid');
    let exit_status =
      match process_status with
      | Unix.WEXITED n -> `Exited n
      | Unix.WSIGNALED n -> `Signaled n [@coverage off]
      | Unix.WSTOPPED n -> `Stopped n [@coverage off]
    in
    exit_status_r := exit_status;
    stdout_r := stdout;
    stderr_r := stderr;
    let exit_code =
      match exit_status with
      | `Exited n -> n
      | (`Signaled _ | `Stopped _) as exit_status ->
        raise_notrace
          (Err.E
             (Err.create
                [ Err.sexp
                    (List
                       [ Atom "process terminated abnormally"
                       ; sexp_field (module Exit_status) "exit_status" exit_status
                       ])
                ])) [@coverage off]
    in
    (* A note regarding the [raise_notrace] below. These cases are indeed
       exercised in the test suite, however bisect_ppx inserts a coverage point
       on the outer edge of the calls, defeating the coverage reports. Thus we
       have to manually disable coverage.

       Illustrating what the inserted unvisitable coverage point looks like:
       {[
         ___bisect_post_visit___ 36 (raise_notrace (Err.E err))
       ]}
    *)
    match
      f (of_process_output { Vcs.Private.Process_output.exit_code; stdout; stderr })
    with
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
             (List
                [ sexp_field (module String) "prog" executable_basename
                ; sexp_field' (List.sexp_of_t String.sexp_of_t) "args" args
                ; sexp_field (module Exit_status) "exit_status" !exit_status_r
                ; sexp_field (module Absolute_path) "cwd" cwd
                ; sexp_field (module Lines) "stdout" (Lines.create !stdout_r)
                ; sexp_field (module Lines) "stderr" (Lines.create !stderr_r)
                ])
         ])
;;

module Make (M : M) = struct
  type nonrec t = t

  let create () = create ~executable_basename:M.executable_basename
  let load_file = load_file
  let save_file = save_file
  let read_dir = read_dir

  let vcs_cli ?env t ~cwd ~args ~f =
    vcs_cli ~of_process_output:M.Output.Private.of_process_output ?env t ~cwd ~args ~f
  ;;
end

module Private = struct
  let find_executable = find_executable
end
