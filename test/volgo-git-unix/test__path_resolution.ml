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

(* In the [Volgo_git_unix] backend, we perform a pre-resolution of the executable
   given the PATH env var, which we characterize in this test. *)

module Unix = UnixLabels

let command cmd =
  let process = Unix.open_process_in (String.concat cmd ~sep:" ") in
  let stdout = In_channel.input_all process in
  let exit_code =
    match Unix.close_process_in process with
    | WEXITED code -> code
    | WSIGNALED _ | WSTOPPED _ -> assert false [@coverage off]
  in
  print_string stdout;
  if exit_code <> 0 then print_endline (Printf.sprintf "[%d]" exit_code)
;;

module Executable_in_path = struct
  [@@@coverage off]

  type t = string option

  let equal t1 t2 = Option.equal String.equal t1 t2
  let to_dyn t = Dyn.option Dyn.string t
end

let%expect_test "hello path" =
  let cwd = Unix.getcwd () |> Absolute_path.v in
  let dir =
    Filename.temp_dir ~temp_dir:(cwd |> Absolute_path.to_string) "vcs_test" ""
    |> Absolute_path.v
  in
  let vcs = Volgo_git_unix.create () in
  let repo_root = Vcs_test_helpers.init vcs ~path:dir in
  let hello_file = Vcs.Path_in_repo.v "hello.txt" in
  Vcs.save_file
    vcs
    ~path:(Vcs.Repo_root.append repo_root hello_file)
    ~file_contents:(Vcs.File_contents.create "Hello World!\n");
  Vcs.add vcs ~repo_root ~path:hello_file;
  let rev =
    Vcs.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "hello commit")
  in
  print_s
    (Vcs.show_file_at_rev vcs ~repo_root ~rev ~path:hello_file
     |> Vcs.File_shown_at_rev.sexp_of_t);
  [%expect {| (Present "Hello World!\n") |}];
  let test_with_env ~vcs ~env ~redact_fields =
    match
      Vcs.Result.git
        ?env
        vcs
        ~repo_root
        ~args:[ "rev-parse"; "INVALID-REF" ]
        ~f:Vcs.Git.Result.exit0
    with
    | Ok _ -> assert false
    | Error err ->
      print_s (Vcs_test_helpers.redact_sexp (Err.sexp_of_t err) ~fields:redact_fields)
  in
  test_with_env ~vcs ~env:None ~redact_fields:[ "cwd"; "prog"; "repo_root"; "stderr" ];
  [%expect
    {|
    ((context (Vcs.git (repo_root <REDACTED>) (args (rev-parse INVALID-REF)))
      ((prog <REDACTED>) (args (rev-parse INVALID-REF))
       (exit_status (Exited 128)) (cwd <REDACTED>) (stdout INVALID-REF)
       (stderr <REDACTED>)))
     (error "Expected exit code 0."))
    |}];
  let bin = Absolute_path.extend cwd (Fsegment.v "bin") in
  Unix.mkdir (bin |> Absolute_path.to_string) ~perm:0o755;
  let git = Absolute_path.extend bin (Fsegment.v "git") in
  Out_channel.with_open_gen
    [ Open_wronly; Open_creat; Open_trunc; Open_binary ]
    0o755
    (git |> Absolute_path.to_string)
    (fun oc ->
       Out_channel.output_string oc "#!/bin/bash -e\necho \"Hello Git!\"\nexit 42\n");
  command [ Absolute_path.to_string git; "hello" ];
  [%expect
    {|
    Hello Git!
    [42]
    |}];
  (* Now let's override the path and monitor which git binary is run. *)
  (* Let's test separately the function that implements the search. *)
  let find_executable ~path = Volgo_git_unix.Runtime.Private.find_executable ~path in
  let result = find_executable ~path:"" in
  require_equal (module Executable_in_path) result None;
  [%expect {||}];
  let result =
    find_executable ~path:(Absolute_path.to_string bin ^ ":" ^ Absolute_path.to_string cwd)
  in
  require_equal (module Executable_in_path) result (Some (Absolute_path.to_string git));
  [%expect {||}];
  let env = Unix.environment () in
  (* If we keep the same PATH as before, the same git binary is run compared to
     before. Indeed the exit code didn't change. *)
  test_with_env
    ~vcs
    ~env:(Some env)
    ~redact_fields:[ "cwd"; "env"; "prog"; "repo_root"; "stderr" ];
  [%expect
    {|
    ((context
      (Vcs.git (repo_root <REDACTED>) (env <REDACTED>)
       (args (rev-parse INVALID-REF)))
      ((prog <REDACTED>) (args (rev-parse INVALID-REF))
       (exit_status (Exited 128)) (cwd <REDACTED>) (stdout INVALID-REF)
       (stderr <REDACTED>)))
     (error "Expected exit code 0."))
    |}];
  (* If we extend the environment in a way that changes PATH, we rerun the
     executable resolution. *)
  let extended_env =
    Array.map env ~f:(fun binding ->
      match String.lsplit2 binding ~on:'=' |> Option.get with
      | "PATH", value -> Printf.sprintf "PATH=%s:%s" (Absolute_path.to_string bin) value
      | _ -> binding)
  in
  (* Under this new environment, we expect out custom git binary to be run instead. *)
  test_with_env
    ~vcs
    ~env:(Some extended_env)
    ~redact_fields:[ "cwd"; "env"; "prog"; "repo_root" ];
  [%expect
    {|
    ((context
      (Vcs.git (repo_root <REDACTED>) (env <REDACTED>)
       (args (rev-parse INVALID-REF)))
      ((prog <REDACTED>) (args (rev-parse INVALID-REF)) (exit_status (Exited 42))
       (cwd <REDACTED>) (stdout "Hello Git!") (stderr "")))
     (error "Expected exit code 0."))
    |}];
  (* When the executable is not present in a custom PATH, we try and execute the
     unqualified executable, which produces an [Unix.ENOENT] error. *)
  let bin2 = Absolute_path.extend cwd (Fsegment.v "bin2") in
  Unix.mkdir (bin2 |> Absolute_path.to_string) ~perm:0o755;
  test_with_env
    ~vcs
    ~env:(Some [| Printf.sprintf "PATH=%s" (Absolute_path.to_string bin2) |])
    ~redact_fields:[ "cwd"; "env"; "repo_root" ];
  [%expect
    {|
    ((context
      (Vcs.git (repo_root <REDACTED>) (env <REDACTED>)
       (args (rev-parse INVALID-REF)))
      ((prog git) (args (rev-parse INVALID-REF)) (exit_status Unknown)
       (cwd <REDACTED>) (stdout "") (stderr "")))
     (error ("Unix.Unix_error(Unix.ENOENT, \"execve\", \"git\")")))
    |}];
  (* Under an empty environment, we expect to revert to the previous git binary. *)
  test_with_env
    ~vcs
    ~env:(Some [||])
    ~redact_fields:[ "cwd"; "env"; "prog"; "repo_root"; "stderr" ];
  [%expect
    {|
    ((context
      (Vcs.git (repo_root <REDACTED>) (env <REDACTED>)
       (args (rev-parse INVALID-REF)))
      ((prog <REDACTED>) (args (rev-parse INVALID-REF))
       (exit_status (Exited 128)) (cwd <REDACTED>) (stdout INVALID-REF)
       (stderr <REDACTED>)))
     (error "Expected exit code 0."))
    |}];
  (* The initial PATH under which the [vcs] is created is used to pre locate the executable. *)
  let save_path = Sys.getenv_opt "PATH" in
  Unix.putenv "PATH" (Absolute_path.to_string bin);
  let vcs = Volgo_git_unix.create () in
  test_with_env ~vcs ~env:None ~redact_fields:[ "cwd"; "env"; "prog"; "repo_root" ];
  [%expect
    {|
    ((context (Vcs.git (repo_root <REDACTED>) (args (rev-parse INVALID-REF)))
      ((prog <REDACTED>) (args (rev-parse INVALID-REF)) (exit_status (Exited 42))
       (cwd <REDACTED>) (stdout "Hello Git!") (stderr "")))
     (error "Expected exit code 0."))
    |}];
  (* Let's monitor the behavior when no Git executable is found in the PATH. In
     this case, the [prog] is left as "git" and we rely on the backend process
     library to raise the error. *)
  Unix.putenv "PATH" (Absolute_path.to_string cwd);
  let vcs = Volgo_git_unix.create () in
  test_with_env ~vcs ~env:None ~redact_fields:[ "cwd"; "env"; "repo_root" ];
  [%expect
    {|
    ((context (Vcs.git (repo_root <REDACTED>) (args (rev-parse INVALID-REF)))
      ((prog git) (args (rev-parse INVALID-REF)) (exit_status Unknown)
       (cwd <REDACTED>) (stdout "") (stderr "")))
     (error ("Unix.Unix_error(Unix.ENOENT, \"execve\", \"git\")")))
    |}];
  Option.iter save_path ~f:(fun path -> Unix.putenv "PATH" path);
  ()
;;
