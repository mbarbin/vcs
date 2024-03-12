(* This is a simple test to make sure we can initialize a repo and commit a
   file, and verify the mock rev mapping. *)

let%expect_test "hello commit" =
  (* We're inside a [Eio] main, that's our chosen runtime for the examples. *)
  let%fun env = Eio_main.run in
  (* To use the [Vcs] API, you need a [vcs] value, which you must obtain from a
     provider. We're using [Vcs_git] for this here. It is a provider based on
     [Eio] and running the [git] command line as an external process. *)
  let vcs = Vcs_git.create ~env in
  (* The next step takes care of creating a repository and initializing the git
     users's config with some dummy values so we can use [commit] without having
     to worry about your user config on your machine. This isolates the test
     from your local settings, and also makes things work when running in the
     GitHub Actions environment, where no default user config exists. *)
  let cwd = Unix.getcwd () |> Absolute_path.v in
  let repo_root = Vcs_for_test.init ~vcs ~path:cwd |> Or_error.ok_exn in
  (* Ok, we are all set, we are now inside a Git repo and we can start using
     [Vcs]. What we do in this example is simply create a new file and commit it
     to the repository, and query it from the store afterwards. *)
  let hello_file = Vcs.Path_in_repo.v "hello.txt" in
  let () =
    (* Just a quick word about [Vcs.save_file]. This is only a part of Vcs that
       is included for convenience. Indeed, this allows a library that uses Vcs
       to perform some basic IO while maintaining compatibility with [Eio] and
       [Blocking] clients. This dispatches to the actual Vcs provider
       implementation, which here uses [Eio.Path.save_file] under the hood. *)
    Vcs.save_file
      vcs
      ~path:(Vcs.Repo_root.append repo_root hello_file)
      ~file_contents:(Vcs.File_contents.create "Hello World!\n")
    |> Or_error.ok_exn
  in
  let () = Vcs.add vcs ~repo_root ~path:hello_file |> Or_error.ok_exn in
  let rev =
    Vcs.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "hello commit")
    |> Or_error.ok_exn
  in
  print_s
    [%sexp
      (Vcs.show_file_at_rev vcs ~repo_root ~rev ~path:hello_file
       : [ `Present of Vcs.File_contents.t | `Absent ] Or_error.t)];
  [%expect {| (Ok (Present "Hello World!\n")) |}];
  ()
;;
