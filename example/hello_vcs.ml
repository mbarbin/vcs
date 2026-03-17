(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* This is a simple test to make sure we can initialize a repo and commit a
   file, and verify the mock rev mapping. *)

let%expect_test "hello commit" =
  (* We're inside a [Eio] main, that's our chosen runtime for the examples. *)
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  (* To use the [Vcs] API, you need a [vcs] value, which you must obtain from a
     backend. We're using [Volgo_git_eio] for this here. It is a backend based
     on [Eio] and running the [git] command line as an external process. *)
  let vcs = Volgo_git_eio.create ~env in
  (* The next step takes care of creating a fresh repository. We make use of a
     helper library to encapsulate the required steps. *)
  let repo_root = Vcs_test_helpers.init_temp_repo ~env ~sw ~vcs in
  (* Ok, we are all set, [repo_root] points to a Git repo and we can start using
     [Vcs]. What we do in this example is simply create a new file and commit it
     to the repository, and query it from the store afterwards. *)
  let hello_file = Vcs.Path_in_repo.v "hello.txt" in
  (* Just a quick word about [Vcs.save_file]. This is only a part of Vcs that is
     included for convenience. Indeed, this allows a library that uses Vcs to
     perform some basic IO while maintaining compatibility with [Volgo_git_eio]
     and [Volgo_git_unix] clients. This dispatches to the actual Vcs backend
     implementation, which here uses [Eio.Path.save_file] under the hood. *)
  Vcs.save_file
    vcs
    ~path:(Vcs.Repo_root.append repo_root hello_file)
    ~file_contents:(Vcs.File_contents.create "Hello World!\n");
  Vcs.add vcs ~repo_root ~path:hello_file;
  let rev =
    Vcs.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "hello commit")
  in
  let () =
    match Vcs.show_file_at_rev vcs ~repo_root ~rev ~path:hello_file with
    | `Absent -> assert false
    | `Present file_contents -> print_dyn (file_contents |> Vcs.File_contents.to_dyn)
  in
  [%expect
    {|
    "Hello World!\n\
     "
    |}];
  ()
;;
