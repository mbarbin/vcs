let%expect_test "init_temp_repo" =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Vcs_git.create ~env in
  let repo_root = Vcs_test_helpers.init_temp_repo ~env ~sw ~vcs in
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
  ()
;;
