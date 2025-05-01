(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
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

(* This test monitors that the [git] runtime functions implemented by the
   [vcs_git_unix] and [vcs_git_eio] backends do respect the specified behavior
   related to exception handling.

   We also check for the occurrence of a regression where the exception handling
   would be defeated by [f] raising the particular [Vcs.E] exception. *)

module _ (S : sig
    (* First let's be reminded of the signature of the [git] function that is
       expected to be implemented by a backend runtime.

       The key here is the overall behavior expected when the [f] argument
       raises. According to the specification, this should be treated as a
       programming error, and the exception shall escape the outer call to
       [git]. *)

    type t

    val git
      :  ?env:string array
      -> t
      -> cwd:Absolute_path.t
      -> args:string list
      -> f:(Vcs.Git.Output.t -> ('a, Vcs.Err.t) Result.t)
      -> ('a, Vcs.Err.t) Result.t
  end) : Vcs.Trait.Git.S = struct
  include S
end

(*  We're creating a type that will instruct a specific handler to cover for
    different scenario, including successful, errors, and raising cases with
    various exceptions. *)

module Handler_scenario = struct
  exception Custom_exception

  type t =
    | Ok
    | Error
    | Raise_failure
    | Raise_invalid_argument
    | Raise_custom_exception
    | Raise_vcs_exception
  [@@deriving enumerate, sexp_of]

  let to_string (t : t) =
    match [%sexp_of: t] t with
    | List _ -> assert false
    | Atom atom -> String.lowercase atom
  ;;
end

let handler (handler_scenario : Handler_scenario.t) =
  match handler_scenario with
  | Ok -> Ok [%sexp ()]
  | Error -> Error (Vcs.Err.error_string "expected exit code 0")
  | Raise_failure -> failwith "Raise_failure"
  | Raise_invalid_argument -> invalid_arg "Raise_invalid_argument"
  | Raise_custom_exception -> raise Handler_scenario.Custom_exception
  | Raise_vcs_exception -> raise (Vcs.E (Vcs.Err.create_s [%sexp "Raise_vcs_exception"]))
;;

let test_current_branch
      (type a)
      (module Runtime : Vcs.Trait.Git.S with type t = a)
      (vcs : a)
      ~repo_root
  =
  let cwd = Vcs.Repo_root.to_absolute_path repo_root in
  let args = [ "rev-parse"; "--abbrev-ref"; "HEAD" ] in
  let f (output : Vcs.Git.Output.t) =
    let output = String.strip output.stdout in
    match
      List.find Handler_scenario.all ~f:(fun handler ->
        String.equal output (Handler_scenario.to_string handler))
    with
    | None -> Ok [%sexp { current_branch = (output : string) }]
    | Some handler_scenario -> handler handler_scenario
  in
  Runtime.git vcs ~cwd ~args ~f
;;

let create_first_commit vcs ~repo_root =
  let hello_file = Vcs.Path_in_repo.v "hello.txt" in
  Vcs.save_file
    vcs
    ~path:(Vcs.Repo_root.append repo_root hello_file)
    ~file_contents:(Vcs.File_contents.create "Hello World!\n");
  Vcs.add vcs ~repo_root ~path:hello_file;
  let (_ : Vcs.Rev.t) =
    Vcs.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "hello commit")
  in
  (* We start the tests from a state where the current branch is "main". *)
  Vcs.rename_current_branch vcs ~repo_root ~to_:Vcs.Branch_name.main
;;

let%expect_test "eio" =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Vcs_git_eio.create ~env in
  let repo_root = Vcs_test_helpers.init_temp_repo ~env ~sw ~vcs in
  create_first_commit vcs ~repo_root;
  let runtime = Vcs_git_eio.Runtime.create ~env in
  let test () = test_current_branch (module Vcs_git_eio.Impl.Git) runtime ~repo_root in
  print_s [%sexp (test () : (Sexp.t, Vcs.Err.t) Result.t)];
  [%expect {| (Ok ((current_branch main))) |}];
  let test_scenario handler_scenario =
    (* We rename the current branch according to the scenario to test. *)
    Vcs.rename_current_branch
      vcs
      ~repo_root
      ~to_:(Vcs.Branch_name.v (Handler_scenario.to_string handler_scenario));
    test ()
  in
  List.iter Handler_scenario.all ~f:(fun handler_scenario ->
    let test () = test_scenario handler_scenario in
    match handler_scenario with
    | Ok ->
      print_s [%sexp (test () : (Sexp.t, Vcs.Err.t) Result.t)];
      [%expect {| (Ok ()) |}]
    | Error ->
      (match test () with
       | Ok (_ : Sexp.t) -> assert false
       | Error err ->
         print_s (Vcs_test_helpers.redact_sexp (Vcs.Err.sexp_of_t err) ~fields:[ "cwd" ]);
         [%expect
           {|
           ((steps ((
              (prog git)
              (args (rev-parse --abbrev-ref HEAD))
              (exit_status (Exited 0))
              (cwd    <REDACTED>)
              (stdout error)
              (stderr ""))))
            (error "expected exit code 0"))
           |}])
    | Raise_failure ->
      require_does_raise [%here] test;
      [%expect {| (Failure Raise_failure) |}]
    | Raise_invalid_argument ->
      require_does_raise [%here] test;
      [%expect {| (Invalid_argument Raise_invalid_argument) |}]
    | Raise_custom_exception ->
      require_does_raise [%here] test;
      [%expect
        {| (Vcs_expect_tests.Git_exception_handler.Handler_scenario.Custom_exception) |}]
    | Raise_vcs_exception ->
      require_does_raise [%here] test;
      [%expect {| (Vcs.E Raise_vcs_exception) |}]);
  ()
;;

let%expect_test "blocking" =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Vcs_git_eio.create ~env in
  let repo_root = Vcs_test_helpers.init_temp_repo ~env ~sw ~vcs in
  create_first_commit vcs ~repo_root;
  let runtime = Vcs_git_unix.Runtime.create () in
  let test () = test_current_branch (module Vcs_git_unix.Impl.Git) runtime ~repo_root in
  print_s [%sexp (test () : (Sexp.t, Vcs.Err.t) Result.t)];
  [%expect {| (Ok ((current_branch main))) |}];
  let test_scenario handler_scenario =
    (* We rename the current branch according to the scenario to test. *)
    Vcs.rename_current_branch
      vcs
      ~repo_root
      ~to_:(Vcs.Branch_name.v (Handler_scenario.to_string handler_scenario));
    test ()
  in
  List.iter Handler_scenario.all ~f:(fun handler_scenario ->
    let test () = test_scenario handler_scenario in
    match handler_scenario with
    | Ok ->
      print_s [%sexp (test () : (Sexp.t, Vcs.Err.t) Result.t)];
      [%expect {| (Ok ()) |}]
    | Error ->
      (match test () with
       | Ok (_ : Sexp.t) -> assert false
       | Error err ->
         print_s
           (Vcs_test_helpers.redact_sexp
              (Vcs.Err.sexp_of_t err)
              ~fields:[ "cwd"; "prog" ]);
         [%expect
           {|
           ((steps ((
              (prog <REDACTED>)
              (args (rev-parse --abbrev-ref HEAD))
              (exit_status (Exited 0))
              (cwd    <REDACTED>)
              (stdout error)
              (stderr ""))))
            (error "expected exit code 0"))
           |}])
    | Raise_failure ->
      require_does_raise [%here] test;
      [%expect {| (Failure Raise_failure) |}]
    | Raise_invalid_argument ->
      require_does_raise [%here] test;
      [%expect {| (Invalid_argument Raise_invalid_argument) |}]
    | Raise_custom_exception ->
      require_does_raise [%here] test;
      [%expect
        {| (Vcs_expect_tests.Git_exception_handler.Handler_scenario.Custom_exception) |}]
    | Raise_vcs_exception ->
      require_does_raise [%here] test;
      [%expect {| (Vcs.E Raise_vcs_exception) |}]);
  ()
;;
