let%expect_test "read_dir" =
  let vcs = Vcs_git_blocking.create () in
  let read_dir dir = print_s [%sexp (Vcs.read_dir vcs ~dir : Fpart.t list)] in
  let cwd = Unix.getcwd () in
  let dir = Stdlib.Filename.temp_dir ~temp_dir:cwd "vcs_test" "" |> Absolute_path.v in
  let save_file file file_contents =
    Vcs.save_file
      vcs
      ~path:(Absolute_path.extend dir (Fpart.v file))
      ~file_contents:(Vcs.File_contents.create file_contents)
  in
  read_dir dir;
  [%expect {| () |}];
  save_file "hello.txt" "Hello World!\n";
  [%expect {||}];
  read_dir dir;
  [%expect {| (hello.txt) |}];
  save_file "foo" "Hello Foo!\n";
  [%expect {||}];
  read_dir dir;
  [%expect {| (foo hello.txt) |}];
  (* Below we redact the actual temporary directory because they make the tests
     non stable. We redact the error when it contains a non-stable path. *)
  let () =
    (* [Vcs.read_dir] errors out on non-existing directories. *)
    match Vcs.read_dir vcs ~dir:(Absolute_path.v "/non-existing") with
    | (_ : Fpart.t list) -> assert false
    | exception Vcs.E err ->
      print_s (Vcs_test_helpers.redact_sexp (Vcs.Err.sexp_of_t err) ~fields:[ "dir" ])
  in
  [%expect
    {|
    ((steps ((Vcs.read_dir ((dir <REDACTED>)))))
     (error (Sys_error "/non-existing: No such file or directory")))
    |}];
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
