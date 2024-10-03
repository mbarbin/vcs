let%expect_test "read_dir" =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Vcs_git_eio.create ~env in
  let repo_root = Vcs_test_helpers.init_temp_repo ~env ~sw ~vcs in
  let dir = Vcs.Repo_root.to_absolute_path repo_root in
  let read_dir dir = print_s [%sexp (Vcs.read_dir vcs ~dir : Fpart.t list)] in
  let save_file file file_contents =
    Vcs.save_file
      vcs
      ~path:(Absolute_path.extend dir (Fpart.v file))
      ~file_contents:(Vcs.File_contents.create file_contents)
  in
  read_dir dir;
  [%expect {| (.git) |}];
  save_file "hello.txt" "Hello World!\n";
  [%expect {||}];
  read_dir dir;
  [%expect {| (.git hello.txt) |}];
  save_file "foo" "Hello Foo!\n";
  [%expect {||}];
  read_dir dir;
  [%expect {| (.git foo hello.txt) |}];
  (* Below we redact the actual temporary directory because they make the tests
     non stable. We redact the error because it either contains the path too, or
     shows very specific Eio messages which may make the test brittle. *)
  let () =
    (* [Vcs.read_dir] errors out on non-existing directories. *)
    match Vcs.read_dir vcs ~dir:(Absolute_path.v "/non-existing") with
    | (_ : Fpart.t list) -> assert false
    | exception Vcs.E err ->
      print_s
        (Vcs_test_helpers.redact_sexp (Vcs.Err.sexp_of_t err) ~fields:[ "dir"; "error" ])
  in
  [%expect {| ((steps ((Vcs.read_dir ((dir <REDACTED>))))) (error <REDACTED>)) |}];
  let () =
    (* [Vcs.read_dir] errors out when called on an existing file rather than a
       directory. *)
    let path = Absolute_path.extend dir (Fpart.v "foo") in
    let file_exists = Stdlib.Sys.file_exists (Absolute_path.to_string path) in
    assert file_exists;
    print_s [%sexp { file_exists : bool }];
    [%expect {| ((file_exists true)) |}];
    match Vcs.read_dir vcs ~dir:path with
    | (_ : Fpart.t list) -> assert false
    | exception Vcs.E err ->
      print_s
        (Vcs_test_helpers.redact_sexp (Vcs.Err.sexp_of_t err) ~fields:[ "dir"; "error" ])
  in
  [%expect {| ((steps ((Vcs.read_dir ((dir <REDACTED>))))) (error <REDACTED>)) |}];
  ()
;;
