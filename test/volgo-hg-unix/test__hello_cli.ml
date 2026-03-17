(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* In this test we cover various code paths for [Vcs.hg] including exception and
   non-raising errors. *)

let%expect_test "hello cli" =
  let vcs = Volgo_hg_unix.create () in
  let mock_revs = Vcs.Mock_revs.create () in
  let temp_dir =
    let cwd = Unix.getcwd () in
    Filename.temp_dir ~temp_dir:cwd "vcs_test" "" |> Absolute_path.v
  in
  let repo_root = Vcs.init vcs ~path:temp_dir in
  let hello_file = Vcs.Path_in_repo.v "hello.txt" in
  Vcs.save_file
    vcs
    ~path:(Vcs.Repo_root.append repo_root hello_file)
    ~file_contents:(Vcs.File_contents.create "Hello World!\n");
  let file_contents =
    Vcs.load_file vcs ~path:(Vcs.Repo_root.append repo_root hello_file)
  in
  print_string (Vcs.File_contents.to_string file_contents);
  [%expect {| Hello World! |}];
  Vcs.add vcs ~repo_root ~path:hello_file;
  let rev =
    Vcs.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "hello commit")
  in
  let mock_rev = Vcs.Mock_revs.to_mock mock_revs ~rev in
  print_dyn (mock_rev |> Vcs.Rev.to_dyn);
  [%expect {| "1185512b92d612b25613f2e5b473e5231185512b" |}];
  let output =
    Vcs.hg
      vcs
      ~repo_root
      ~args:
        (List.concat
           [ [ "cat"; Vcs.Path_in_repo.to_string hello_file ]
           ; [ "-r"; Vcs.Rev.to_string rev ]
           ])
      ~f:Vcs.Hg.exit0_and_stdout
  in
  print_endline output;
  [%expect {| Hello World! |}];
  let hg_rev =
    match
      Vcs.Result.hg
        vcs
        ~repo_root
        ~args:(List.concat [ [ "log" ]; [ "-r"; "." ]; [ "--template"; "{node}" ] ])
        ~f:(fun output ->
          let open Result.Syntax in
          let* stdout = Vcs.Hg.Result.exit0_and_stdout output in
          match Vcs.Rev.of_string (String.strip stdout) with
          | Ok _ as ok -> ok
          | Error _ -> assert false)
    with
    | Ok ok -> ok
    | Error _ -> assert false
  in
  require_equal (module Vcs.Rev) rev hg_rev;
  [%expect {||}];
  let mock_rev2 = Vcs.Mock_revs.to_mock mock_revs ~rev:hg_rev in
  print_dyn (mock_rev2 |> Vcs.Rev.to_dyn);
  [%expect {| "1185512b92d612b25613f2e5b473e5231185512b" |}];
  let () =
    match Vcs.hg vcs ~repo_root ~args:[ "bogus" ] ~f:Vcs.Hg.exit0 with
    | _ -> assert false
    | exception Err.E err ->
      print_s
        (Vcs_test_helpers.redact_sexp
           (err |> Err.sexp_of_t)
           ~fields:[ "cwd"; "prog"; "repo_root"; "stderr" ])
  in
  [%expect
    {|
    ((context (Vcs.hg (repo_root <REDACTED>) (args (bogus)))
      ((prog <REDACTED>) (args (bogus)) (exit_status (Exited 255))
       (cwd <REDACTED>) (stdout "") (stderr <REDACTED>)))
     (error "Expected exit code 0."))
    |}];
  let () =
    match
      Vcs.hg
        vcs
        ~env:[| "HELLO=env" |]
        ~run_in_subdir:Vcs.Path_in_repo.root
        ~repo_root
        ~args:[ "bogus" ]
        ~f:Vcs.Hg.exit0
    with
    | _ -> assert false
    | exception Err.E err ->
      print_s
        (Vcs_test_helpers.redact_sexp
           (err |> Err.sexp_of_t)
           ~fields:[ "cwd"; "prog"; "repo_root"; "stderr" ])
  in
  [%expect
    {|
    ((context
      (Vcs.hg (repo_root <REDACTED>) (run_in_subdir ./) (env (HELLO=env))
       (args (bogus)))
      ((prog <REDACTED>) (args (bogus)) (exit_status (Exited 255))
       (cwd <REDACTED>) (stdout "") (stderr <REDACTED>)))
     (error "Expected exit code 0."))
    |}];
  let () =
    match Vcs.Result.hg vcs ~repo_root ~args:[ "bogus" ] ~f:Vcs.Hg.Result.exit0 with
    | Ok _ -> assert false
    | Error err ->
      print_s
        (Vcs_test_helpers.redact_sexp
           (err |> Err.sexp_of_t)
           ~fields:[ "cwd"; "prog"; "repo_root"; "stderr" ])
  in
  [%expect
    {|
    ((context (Vcs.hg (repo_root <REDACTED>) (args (bogus)))
      ((prog <REDACTED>) (args (bogus)) (exit_status (Exited 255))
       (cwd <REDACTED>) (stdout "") (stderr <REDACTED>)))
     (error "Expected exit code 0."))
    |}];
  ()
;;
