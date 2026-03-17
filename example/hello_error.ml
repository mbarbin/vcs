(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* In this test we run a function from the Vcs API, let it raise an exception
   and show how to catch it. This allows for a basic coverage of the raising
   case of the API too. *)

let%expect_test "hello error" =
  Eio_main.run
  @@ fun env ->
  let vcs = Volgo_git_eio.create ~env in
  let invalid_path = Absolute_path.v "/invalid/path" in
  let redact_sexp sexp =
    (* Because the actual error may become too brittle overtime, we actually
       redact it. *)
    Vcs_test_helpers.redact_sexp sexp ~fields:[ "error" ]
  in
  let () =
    match Vcs.init vcs ~path:invalid_path with
    | _ -> assert false
    | exception Err.E err -> print_s (redact_sexp (err |> Err.sexp_of_t))
  in
  [%expect
    {|
    ((context (Vcs.init (path /invalid/path))
      ((prog git) (args (init .)) (exit_status Unknown) (cwd /invalid/path)
       (stdout "") (stderr "")))
     (error <REDACTED>))
    |}];
  (* Let's do the same with the non-raising interfaces. *)
  let () =
    match Vcs.Result.init vcs ~path:invalid_path with
    | Ok _ -> assert false
    | Error err -> print_s (redact_sexp (err |> Err.sexp_of_t))
  in
  [%expect
    {|
    ((context (Vcs.init (path /invalid/path))
      ((prog git) (args (init .)) (exit_status Unknown) (cwd /invalid/path)
       (stdout "") (stderr "")))
     (error <REDACTED>))
    |}];
  let () =
    match Vcs.Result.init vcs ~path:invalid_path with
    | Ok _ -> assert false
    | Error err -> print_s (redact_sexp (err |> Err.sexp_of_t))
  in
  [%expect
    {|
    ((context (Vcs.init (path /invalid/path))
      ((prog git) (args (init .)) (exit_status Unknown) (cwd /invalid/path)
       (stdout "") (stderr "")))
     (error <REDACTED>))
    |}];
  let () =
    match Vcs.Rresult.init vcs ~path:invalid_path with
    | Ok _ -> assert false
    | Error err -> print_s (redact_sexp (err |> Vcs.Rresult.sexp_of_err))
  in
  [%expect
    {|
    (Vcs
     ((context (Vcs.init (path /invalid/path))
       ((prog git) (args (init .)) (exit_status Unknown) (cwd /invalid/path)
        (stdout "") (stderr "")))
      (error <REDACTED>)))
    |}];
  ()
;;
