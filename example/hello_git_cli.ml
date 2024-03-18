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

(** In this example, we show that when we're using a provider based on a Git
    CLI, we can use it to manually run git commands. *)

let%expect_test "hello cli" =
  (* We're inside a [Eio] main, that's our chosen runtime for the examples. *)
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Vcs_git.create ~env in
  let repo_root =
    let path = Stdlib.Filename.temp_dir ~temp_dir:(Unix.getcwd ()) "vcs" "test" in
    Eio.Switch.on_release sw (fun () ->
      Eio.Path.rmtree Eio.Path.(Eio.Stdenv.fs env / path));
    Vcs.For_test.init vcs ~path:(Absolute_path.v path) |> Or_error.ok_exn
  in
  let hello_file = Vcs.Path_in_repo.v "hello.txt" in
  Vcs.save_file
    vcs
    ~path:(Vcs.Repo_root.append repo_root hello_file)
    ~file_contents:(Vcs.File_contents.create "Hello World!\n");
  Vcs.add vcs ~repo_root ~path:hello_file;
  let rev =
    Vcs.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "hello commit")
  in
  let () =
    (* Let's make sure the branch name is deterministic in this test rather than
       depending on a reachable user config. *)
    Vcs.rename_current_branch vcs ~repo_root ~to_:Vcs.Branch_name.main
  in
  Vcs.git
    vcs
    ~repo_root
    ~args:
      [ "show"
      ; Printf.sprintf
          "%s:%s"
          (Vcs.Rev.to_string rev)
          (Vcs.Path_in_repo.to_string hello_file)
      ]
    ~f:(fun { exit_code; stdout; stderr = _ } ->
      print_endline (Printf.sprintf "exit code: %d" exit_code);
      print_endline (Printf.sprintf "stdout:\n%s%s" stdout (String.make 15 '-')));
  [%expect {|
    exit code: 0
    stdout:
    Hello World!
    --------------- |}];
  (* Let's show also how to use the git cli in a case where we'd like to parse
     its output, and how to do this with the non-parsing API of Vcs. *)
  let head_rev =
    Vcs.Or_error.git vcs ~repo_root ~args:[ "rev-parse"; "HEAD" ] ~f:(fun output ->
      let%bind stdout = Vcs.Git.exit0_and_stdout output in
      Vcs.Rev.of_string (String.strip stdout))
    |> Or_error.ok_exn
  in
  require_equal [%here] (module Vcs.Rev) rev head_rev;
  [%expect {||}];
  (* Let's do one with [Vcs.Result.git]. *)
  let abbrev_head =
    match
      Vcs.Result.git
        vcs
        ~repo_root
        ~args:[ "rev-parse"; "--abbrev-ref"; "HEAD" ]
        ~f:(fun output -> Result.return output.stdout)
    with
    | Ok stdout -> stdout
    | Error _ -> assert false
  in
  print_string abbrev_head;
  [%expect {| main |}];
  (* Let's also show a case where the command fails. *)
  let () =
    match
      Vcs.Result.git vcs ~repo_root ~args:[ "rev-parse"; "INVALID-REF" ] ~f:(fun output ->
        if output.exit_code = 0
        then assert false [@coverage off]
        else Error (`Vcs (Vcs.Err.create_s [%sexp "Hello invalid exit code"])))
    with
    | Ok _ -> assert false
    | Error (`Vcs err) ->
      (* Here we do not show the entire sexp because it is too unstable. Indeed,
         it contains the whole context of the failure, including stderr, steps,
         etc. For the purpose of the test here, we only verify that the error
         message that the user provided is included. *)
      let rec visit : Sexp.t -> bool = function
        | List [ Atom "error"; Atom user_error ] ->
          print_endline user_error;
          true
        | Atom _ -> false
        | List sexps -> List.exists sexps ~f:visit
      in
      assert (visit (Vcs.Err.sexp_of_t err))
  in
  [%expect {| Hello invalid exit code |}];
  ()
;;
