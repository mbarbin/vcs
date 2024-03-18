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

(* This is a simple test to show how to use the blocking interface of [Vcs]. *)

let%expect_test "hello commit" =
  (* To use the [Vcs] API, you need a [vcs] value, which you must obtain from a
     provider. We're using [Vcs_git_blocking] for this here. It is a provider
     based on [Stdlib] and running the [git] command line as an external
     process. *)
  let vcs = Vcs_git_blocking.create () in
  (* The next step takes care of creating a repository and initializing the git
     users's config with some dummy values so we can use [commit] without having
     to worry about your user config on your machine. This isolates the test
     from your local settings, and also makes things work when running in the
     GitHub Actions environment, where no default user config exists. *)
  let repo_root =
    let path = Stdlib.Filename.temp_dir ~temp_dir:(Unix.getcwd ()) "vcs" "test" in
    Vcs.For_test.init vcs ~path:(Absolute_path.v path) |> Or_error.ok_exn
  in
  (* Ok, we are all set, we are now inside a Git repo and we can start using
     [Vcs]. What we do in this example is simply create a new file and commit it
     to the repository, and query it from the store afterwards. *)
  let hello_file = Vcs.Path_in_repo.v "hello.txt" in
  (* Just a quick word about [Vcs.save_file]. This is only a part of Vcs that is
     included for convenience. Indeed, this allows a library that uses Vcs to
     perform some basic IO while maintaining compatibility with [Eio] and
     [Blocking] clients. This dispatches to the actual Vcs provider
     implementation, which here uses [Stdlib.Out_channel] under the hood. *)
  Vcs.save_file
    vcs
    ~path:(Vcs.Repo_root.append repo_root hello_file)
    ~file_contents:(Vcs.File_contents.create "Hello World!\n");
  Vcs.add vcs ~repo_root ~path:hello_file;
  let rev =
    Vcs.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "hello commit")
  in
  print_s
    [%sexp
      (Vcs.Or_error.show_file_at_rev vcs ~repo_root ~rev ~path:hello_file
       : [ `Present of Vcs.File_contents.t | `Absent ] Or_error.t)];
  [%expect {| (Ok (Present "Hello World!\n")) |}];
  (* Let's cover a case where the command fails. *)
  let () =
    match
      Vcs.Result.git
        vcs
        ~repo_root:(Vcs.Repo_root.v "/invalid/path")
        ~args:[]
        ~f:Result.return
    with
    | Ok _ -> assert false
    | Error (`Vcs err) -> print_s (Vcs.Err.sexp_of_t err)
  in
  [%expect
    {|
    ((steps ((
       Vcs.git (
         (repo_root /invalid/path)
         (run_in_subdir ())
         (env           ())
         (args          ())))))
     (error (
       (prog git)
       (args ())
       (exit_status Unknown)
       (cwd         /invalid/path/)
       (stdout      "")
       (stderr      "")
       (error ("Unix.Unix_error(Unix.ENOENT, \"chdir\", \"/invalid/path/\")"))))) |}];
  (* Let's also show a case where the command fails due to a user error. *)
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
  (* Here we only use [Eio] to clean up the temporary repo, because [rmtree] is
     a convenient function to use in this test. But the point is that the rest
     of the test used a blocking API. *)
  Eio_main.run
  @@ fun env ->
  Eio.Path.rmtree Eio.Path.(Eio.Stdenv.fs env / Vcs.Repo_root.to_string repo_root);
  ()
;;
