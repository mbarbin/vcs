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

(* In this example, we show that when we're using a backend based on a Git CLI,
   we can use it to manually run git commands. *)

let%expect_test "hello cli" =
  (* We're inside a [Eio] main, that's our chosen runtime for the examples. *)
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Volgo_git_eio.create ~env in
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
  (* Let's show also how to use the git cli in a case where we'd like to parse
     its output, and how to do this with the non-raising API of Vcs. *)
  let head_rev =
    Vcs.Or_error.git vcs ~repo_root ~args:[ "rev-parse"; "HEAD" ] ~f:(fun output ->
      let%bind.Or_error stdout = Vcs.Git.Or_error.exit0_and_stdout output in
      match Vcs.Rev.of_string (String.strip stdout) with
      | Ok _ as ok -> ok
      | Error (`Msg _) -> assert false)
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
  (* Cases where the command fails. *)
  let () =
    match
      Vcs.git
        vcs
        ~run_in_subdir:Vcs.Path_in_repo.root
        ~repo_root
        ~args:[ "rev-parse"; "INVALID-REF" ]
        ~f:(fun output ->
          if output.exit_code = 0
          then assert false [@coverage off]
          else failwith "Hello invalid exit code")
    with
    | _ -> assert false [@coverage off]
    | exception Err.E err ->
      print_s
        (Vcs_test_helpers.redact_sexp
           [%sexp (err : Err.t)]
           ~fields:[ "cwd"; "repo_root"; "stderr" ])
  in
  [%expect
    {|
    ((context
      (Vcs.git (repo_root <REDACTED>) (run_in_subdir ./)
       (args (rev-parse INVALID-REF)))
      ((prog git) (args (rev-parse INVALID-REF)) (exit_status (Exited 128))
       (cwd <REDACTED>) (stdout INVALID-REF) (stderr <REDACTED>)))
     (error (Failure "Hello invalid exit code")))
    |}];
  let () =
    match
      Vcs.Or_error.git
        vcs
        ~repo_root
        ~args:[ "rev-parse"; "INVALID-REF" ]
        ~f:(fun output ->
          if output.exit_code = 0
          then assert false [@coverage off]
          else Or_error.error_string "Hello invalid exit code")
    with
    | Ok _ -> assert false
    | Error error ->
      print_s
        (Vcs_test_helpers.redact_sexp
           [%sexp (error : Error.t)]
           ~fields:[ "cwd"; "repo_root"; "stderr" ])
  in
  [%expect
    {|
    ((context (Vcs.git (repo_root <REDACTED>) (args (rev-parse INVALID-REF)))
      ((prog git) (args (rev-parse INVALID-REF)) (exit_status (Exited 128))
       (cwd <REDACTED>) (stdout INVALID-REF) (stderr <REDACTED>)))
     (error "Hello invalid exit code"))
    |}];
  let () =
    match
      Vcs.Result.git vcs ~repo_root ~args:[ "rev-parse"; "INVALID-REF" ] ~f:(fun output ->
        if output.exit_code = 0
        then assert false [@coverage off]
        else Error (Err.create [ Pp.text "Hello invalid exit code." ]))
    with
    | Ok _ -> assert false
    | Error err ->
      print_s
        (Vcs_test_helpers.redact_sexp
           [%sexp (err : Err.t)]
           ~fields:[ "cwd"; "repo_root"; "stderr" ])
  in
  [%expect
    {|
    ((context (Vcs.git (repo_root <REDACTED>) (args (rev-parse INVALID-REF)))
      ((prog git) (args (rev-parse INVALID-REF)) (exit_status (Exited 128))
       (cwd <REDACTED>) (stdout INVALID-REF) (stderr <REDACTED>)))
     (error "Hello invalid exit code."))
    |}];
  let () =
    match
      Vcs.Rresult.git
        vcs
        ~repo_root
        ~args:[ "rev-parse"; "INVALID-REF" ]
        ~f:(fun output ->
          if output.exit_code = 0
          then assert false [@coverage off]
          else Error (`Vcs (Err.create [ Pp.text "Hello invalid exit code." ])))
    with
    | Ok _ -> assert false
    | Error (`Vcs err) ->
      print_s
        (Vcs_test_helpers.redact_sexp
           [%sexp (err : Err.t)]
           ~fields:[ "cwd"; "repo_root"; "stderr" ])
  in
  [%expect
    {|
    ((context (Vcs.git (repo_root <REDACTED>) (args (rev-parse INVALID-REF)))
      ((prog git) (args (rev-parse INVALID-REF)) (exit_status (Exited 128))
       (cwd <REDACTED>) (stdout INVALID-REF) (stderr <REDACTED>)))
     (error "Hello invalid exit code."))
    |}];
  (* Here we characterize some unintended ways the API may be abused. *)
  (* 1. [Vcs.git] is meant to be used with a raising helper. In this section we
     show undesirable effect of using it with a non-raising helper [f]. *)
  let abbrev_ref ?(repo_root = repo_root) ref_ =
    Vcs.git
      vcs
      ~repo_root
      ~args:[ "rev-parse"; "--abbrev-ref"; ref_ ]
      ~f:Vcs.Git.Or_error.exit0_and_stdout
    |> Or_error.map ~f:String.strip
  in
  (* You may be tempted to think the setup is ok, based on the happy path
     behavior. *)
  print_s [%sexp (abbrev_ref "HEAD" : string Or_error.t)];
  [%expect {| (Ok main) |}];
  (* However, note that the call can still raise, despite its [Result] return type. *)
  let () =
    match abbrev_ref ~repo_root:(Vcs.Repo_root.v "/bogus") "HEAD" with
    | Ok (_ : string) | Error (_ : Error.t) -> assert false [@coverage off]
    | exception Err.E err ->
      print_s (Vcs_test_helpers.redact_sexp [%sexp (err : Err.t)] ~fields:[ "error" ])
  in
  [%expect
    {|
    ((context (Vcs.git (repo_root /bogus) (args (rev-parse --abbrev-ref HEAD)))
      ((prog git) (args (rev-parse --abbrev-ref HEAD)) (exit_status Unknown)
       (cwd /bogus/) (stdout "") (stderr "")))
     (error <REDACTED>))
    |}];
  (* Another difference is that you do not get the context when the [f] helper
     returns an error. *)
  print_s [%sexp (abbrev_ref "/bogus" : string Or_error.t)];
  [%expect {| (Error "Expected exit code 0.") |}];
  (* If you are using a non-raising handler [f], you probably meant to use
     [Vcs.Or_error.git]. The type of [abbrev_ref] is the same. *)
  let abbrev_ref ?(repo_root = repo_root) ref_ =
    Vcs.Or_error.git
      vcs
      ~repo_root
      ~args:[ "rev-parse"; "--abbrev-ref"; ref_ ]
      ~f:Vcs.Git.Or_error.exit0_and_stdout
    |> Or_error.map ~f:String.strip
  in
  (* The behavior is the same in the happy path. *)
  print_s [%sexp (abbrev_ref "HEAD" : string Or_error.t)];
  [%expect {| (Ok main) |}];
  (* However, now the function will not raise. *)
  print_s
    (Vcs_test_helpers.redact_sexp
       [%sexp
         (abbrev_ref ~repo_root:(Vcs.Repo_root.v "/bogus") "HEAD" : string Or_error.t)]
       ~fields:[ "error" ]);
  [%expect
    {|
    (Error
     ((context (Vcs.git (repo_root /bogus) (args (rev-parse --abbrev-ref HEAD)))
       ((prog git) (args (rev-parse --abbrev-ref HEAD)) (exit_status Unknown)
        (cwd /bogus/) (stdout "") (stderr "")))
      (error <REDACTED>)))
    |}];
  (* And you do get the context when the helper returns an error. *)
  let error_with_context =
    match abbrev_ref "bogus" with
    | Ok _ -> assert false [@coverage off]
    | Error error -> Error.sexp_of_t error
  in
  print_s
    (Vcs_test_helpers.redact_sexp
       error_with_context
       ~fields:[ "cwd"; "repo_root"; "stderr" ]);
  [%expect
    {|
    ((context
      (Vcs.git (repo_root <REDACTED>) (args (rev-parse --abbrev-ref bogus)))
      ((prog git) (args (rev-parse --abbrev-ref bogus))
       (exit_status (Exited 128)) (cwd <REDACTED>) (stdout bogus)
       (stderr <REDACTED>)))
     (error "Expected exit code 0."))
    |}];
  (* 2. Let's look now at [Vcs.Or_error.git]. It is meant to be used with a
     non-raising handler [f]. Let's see what happens when [f] raises. *)
  let abbrev_ref ?(repo_root = repo_root) ref_ =
    Vcs.Or_error.git
      vcs
      ~repo_root
      ~args:[ "rev-parse"; "--abbrev-ref"; ref_ ]
      ~f:(fun { exit_code; stdout; stderr = _ } ->
        match exit_code with
        | 0 -> Or_error.return (String.strip stdout)
        | _ -> failwith "Unexpected error code")
  in
  (* You may be tempted to think the setup is ok, based on the happy path
     behavior. *)
  print_s [%sexp (abbrev_ref "HEAD" : string Or_error.t)];
  [%expect {| (Ok main) |}];
  (* Some error condition will even correctly be turned into Errors, which may
     further prevent you from hitting a raising case. *)
  print_s
    (Vcs_test_helpers.redact_sexp
       [%sexp
         (abbrev_ref ~repo_root:(Vcs.Repo_root.v "/bogus") "HEAD" : string Or_error.t)]
       ~fields:[ "error" ]);
  [%expect
    {|
    (Error
     ((context (Vcs.git (repo_root /bogus) (args (rev-parse --abbrev-ref HEAD)))
       ((prog git) (args (rev-parse --abbrev-ref HEAD)) (exit_status Unknown)
        (cwd /bogus/) (stdout "") (stderr "")))
      (error <REDACTED>)))
    |}];
  (* However when your handler [f] raises, the function will raise too, and you
     won't get the context in this case. *)
  require_does_raise [%here] (fun () : string Or_error.t -> abbrev_ref "/bogus");
  [%expect {| (Failure "Unexpected error code") |}];
  (* If you use a raising handler [f], you probably meant to use [Vcs.git]. *)
  let abbrev_ref ?(repo_root = repo_root) ref_ =
    Vcs.git
      vcs
      ~repo_root
      ~args:[ "rev-parse"; "--abbrev-ref"; ref_ ]
      ~f:(fun { exit_code; stdout; stderr = _ } ->
        match exit_code with
        | 0 -> String.strip stdout
        | _ -> failwith "Unexpected error code" [@coverage off])
  in
  (* You get a function that does not raise in the happy path. *)
  print_s [%sexp (abbrev_ref "HEAD" : string)];
  [%expect {| main |}];
  (* And always raises [Err.E], with context, whether the error comes from your handler or not. *)
  let abbrev_ref_does_raise ?repo_root ref_ ~redact_fields =
    match abbrev_ref ?repo_root ref_ with
    | _ -> assert false [@coverage off]
    | exception Err.E err ->
      print_s (Vcs_test_helpers.redact_sexp (Err.sexp_of_t err) ~fields:redact_fields)
  in
  abbrev_ref_does_raise
    ~repo_root:(Vcs.Repo_root.v "/bogus")
    "HEAD"
    ~redact_fields:[ "cwd"; "error"; "repo_root"; "stderr" ];
  [%expect
    {|
    ((context
      (Vcs.git (repo_root <REDACTED>) (args (rev-parse --abbrev-ref HEAD)))
      ((prog git) (args (rev-parse --abbrev-ref HEAD)) (exit_status Unknown)
       (cwd <REDACTED>) (stdout "") (stderr <REDACTED>)))
     (error <REDACTED>))
    |}];
  abbrev_ref_does_raise "bogus" ~redact_fields:[ "cwd"; "repo_root"; "stderr" ];
  [%expect
    {|
    ((context
      (Vcs.git (repo_root <REDACTED>) (args (rev-parse --abbrev-ref bogus)))
      ((prog git) (args (rev-parse --abbrev-ref bogus))
       (exit_status (Exited 128)) (cwd <REDACTED>) (stdout bogus)
       (stderr <REDACTED>)))
     (error (Failure "Unexpected error code")))
    |}];
  ()
;;
