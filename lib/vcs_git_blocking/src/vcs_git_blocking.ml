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

module Runtime = struct
  type t = unit

  let name _ = "git-blocking"
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

  type exit_status =
    [ `Exited of int
    | `Signaled of int
    | `Stopped of int
    | `Unknown
    ]
  [@@deriving sexp_of]

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
      | Some env -> env
    in
    let exit_status_r : exit_status ref = ref `Unknown in
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
        | Unix.WSIGNALED n -> `Signaled n
        | Unix.WSTOPPED n -> `Stopped n
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
          ; exit_status = (!exit_status_r : exit_status)
          ; cwd : Absolute_path.t
          ; stdout = (Lines.create !stdout_r : Lines.t)
          ; stderr = (Lines.create !stderr_r : Lines.t)
          ; error : Error.t
          }]
  ;;
end

(* CR mbarbin: Share this within [Git_cli] so it isn't duplicated with
   [Vcs_git]. *)
module Impl = struct
  include Runtime
  module Add = Git_cli.Add.Make (Runtime)
  module Branch = Git_cli.Branch.Make (Runtime)
  module Commit = Git_cli.Commit.Make (Runtime)
  module Config = Git_cli.Config.Make (Runtime)
  module File_system = Runtime
  module Git = Runtime
  module Init = Git_cli.Init.Make (Runtime)
  module Log = Git_cli.Log.Make (Runtime)
  module Ls_files = Git_cli.Ls_files.Make (Runtime)
  module Name_status = Git_cli.Name_status.Make (Runtime)
  module Num_status = Git_cli.Num_status.Make (Runtime)
  module Refs = Git_cli.Refs.Make (Runtime)
  module Rev_parse = Git_cli.Rev_parse.Make (Runtime)
  module Show = Git_cli.Show.Make (Runtime)
end

type tag =
  [ Vcs.Trait.add
  | Vcs.Trait.branch
  | Vcs.Trait.commit
  | Vcs.Trait.config
  | Vcs.Trait.file_system
  | Vcs.Trait.git
  | Vcs.Trait.init
  | Vcs.Trait.log
  | Vcs.Trait.ls_files
  | Vcs.Trait.name_status
  | Vcs.Trait.num_status
  | Vcs.Trait.refs
  | Vcs.Trait.rev_parse
  | Vcs.Trait.show
  ]

type 'a t = ([> tag ] as 'a) Vcs.t
type t' = tag t

let interface () : (Impl.t, [> tag ]) Provider.Interface.t =
  Provider.Interface.make
    [ Provider.Trait.implement Vcs.Trait.Add ~impl:(module Impl.Add)
    ; Provider.Trait.implement Vcs.Trait.Branch ~impl:(module Impl.Branch)
    ; Provider.Trait.implement Vcs.Trait.Commit ~impl:(module Impl.Commit)
    ; Provider.Trait.implement Vcs.Trait.Config ~impl:(module Impl.Config)
    ; Provider.Trait.implement Vcs.Trait.File_system ~impl:(module Impl.File_system)
    ; Provider.Trait.implement Vcs.Trait.Git ~impl:(module Impl.Git)
    ; Provider.Trait.implement Vcs.Trait.Init ~impl:(module Impl.Init)
    ; Provider.Trait.implement Vcs.Trait.Log ~impl:(module Impl.Log)
    ; Provider.Trait.implement Vcs.Trait.Ls_files ~impl:(module Impl.Ls_files)
    ; Provider.Trait.implement Vcs.Trait.Name_status ~impl:(module Impl.Name_status)
    ; Provider.Trait.implement Vcs.Trait.Num_status ~impl:(module Impl.Num_status)
    ; Provider.Trait.implement Vcs.Trait.Refs ~impl:(module Impl.Refs)
    ; Provider.Trait.implement Vcs.Trait.Rev_parse ~impl:(module Impl.Rev_parse)
    ; Provider.Trait.implement Vcs.Trait.Show ~impl:(module Impl.Show)
    ]
;;

let create () = Vcs.create (Provider.T { t = Impl.create (); interface = interface () })
