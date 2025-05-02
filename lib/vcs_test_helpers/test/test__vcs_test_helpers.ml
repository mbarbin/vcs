(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
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

let%expect_test "init_temp_repo" =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Vcs_git_eio.create ~env in
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
  [%expect
    {|
    exit code: 0
    stdout:
    Hello World!
    --------------- |}];
  ()
;;

let%expect_test "redact_sexp" =
  Eio_main.run
  @@ fun env ->
  let vcs = Vcs_git_eio.create ~env in
  let invalid_path = Absolute_path.v "/invalid/path" in
  let error =
    match Vcs.init vcs ~path:invalid_path with
    | _ -> assert false
    | exception Vcs.E err -> [%sexp (err : Vcs.Err.t)]
  in
  print_s (Vcs_test_helpers.redact_sexp error ~fields:[ "error" ]);
  [%expect
    {|
    ((steps (
       (Vcs.init ((path /invalid/path)))
       ((prog git)
        (args (init .))
        (exit_status Unknown)
        (cwd         /invalid/path)
        (stdout      "")
        (stderr      ""))))
     (error <REDACTED>))
    |}];
  print_s (Vcs_test_helpers.redact_sexp error ~fields:[ "error"; "steps/cwd" ]);
  [%expect
    {|
    ((steps (
       (Vcs.init ((path /invalid/path)))
       ((prog git)
        (args (init .))
        (exit_status Unknown)
        (cwd         <REDACTED>)
        (stdout      "")
        (stderr      ""))))
     (error <REDACTED>))
    |}];
  print_s (Vcs_test_helpers.redact_sexp error ~fields:[ "error"; "steps/stderr"; "cwd" ]);
  [%expect
    {|
    ((steps (
       (Vcs.init ((path /invalid/path)))
       ((prog git)
        (args (init .))
        (exit_status Unknown)
        (cwd         <REDACTED>)
        (stdout      "")
        (stderr      <REDACTED>))))
     (error <REDACTED>))
    |}];
  (* Adding corner cases, such as empty nested fields. *)
  let sexp =
    Sexp.(
      List
        [ List [ Atom ""; Atom "empty" ]
        ; List [ Atom ""; List [ Atom ""; Atom "empty" ] ]
        ; List [ Atom "error"; Atom "error" ]
        ])
  in
  print_s (Vcs_test_helpers.redact_sexp sexp ~fields:[]);
  [%expect {| (("" empty) ("" ("" empty)) (error error)) |}];
  print_s (Vcs_test_helpers.redact_sexp sexp ~fields:[ "" ]);
  [%expect
    {|
    ((""    <REDACTED>)
     (""    <REDACTED>)
     (error error))
    |}];
  print_s (Vcs_test_helpers.redact_sexp sexp ~fields:[ "/" ]);
  [%expect {| (("" empty) ("" ("" <REDACTED>)) (error error)) |}];
  ()
;;
