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

(* A utility to map the revisions to short and stable keys ("rev0", "rev1", etc). *)

module Rev_table = Vcs.Private.Rev_table

let map_sexp =
  let next = ref (-1) in
  let revs = Rev_table.create 128 in
  let redact rev =
    match Rev_table.find revs rev with
    | Some redacted -> redacted
    | None ->
      let redacted =
        Int.incr next;
        let n = !next in
        Printf.sprintf "rev%d" n
      in
      Rev_table.add_exn revs ~key:rev ~data:redacted;
      redacted
  in
  let rec aux sexp : Sexp.t =
    match (sexp : Sexp.t) with
    | List sexps -> List (List.map sexps ~f:aux)
    | Atom rev ->
      (match Vcs.Rev.of_string rev with
       | Error _ -> sexp
       | Ok rev -> Atom (redact rev))
  in
  aux
;;

let%expect_test "small graph" =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Volgo_git_eio.create ~env in
  let mock_revs = Vcs.Mock_revs.create () in
  let repo_root = Vcs_test_helpers.init_temp_repo ~env ~sw ~vcs in
  let () =
    match
      Vcs.Or_error.add vcs ~repo_root ~path:(Vcs.Path_in_repo.v "unknown-file.txt")
    with
    | Ok () -> assert false
    | Error e ->
      print_s
        (Vcs_test_helpers.redact_sexp
           (e |> Error.sexp_of_t)
           ~fields:[ "cwd"; "repo_root" ])
  in
  [%expect
    {|
    ((context (Vcs.add (repo_root <REDACTED>) (path unknown-file.txt))
      ((prog git) (args (add unknown-file.txt)) (exit_status (Exited 128))
       (cwd <REDACTED>) (stdout "")
       (stderr "fatal: pathspec 'unknown-file.txt' did not match any files")))
     (error "Expected exit code 0."))
    |}];
  let () =
    match
      Vcs.Or_error.commit
        vcs
        ~repo_root
        ~commit_message:(Vcs.Commit_message.v "Nothing to commit")
    with
    | Ok (_ : Vcs.Rev.t) -> assert false
    | Error e ->
      print_s
        (Vcs_test_helpers.redact_sexp
           (e |> Error.sexp_of_t)
           ~fields:[ "cwd"; "repo_root"; "stdout" ])
  in
  [%expect
    {|
    ((context (Vcs.commit (repo_root <REDACTED>))
      ((prog git) (args (commit -m "Nothing to commit")) (exit_status (Exited 1))
       (cwd <REDACTED>) (stdout <REDACTED>) (stderr "")))
     (error "Expected exit code 0."))
    |}];
  let commit_file ~path ~file_contents =
    let result =
      let open Or_error.Let_syntax in
      let%bind () =
        Vcs.Or_error.save_file
          vcs
          ~path:(Vcs.Repo_root.append repo_root path)
          ~file_contents:(Vcs.File_contents.create file_contents)
      in
      let%bind () = Vcs.Or_error.add vcs ~repo_root ~path in
      Vcs.Or_error.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "_")
    in
    Or_error.ok_exn result
  in
  let hello_file = Vcs.Path_in_repo.v "hello.txt" in
  let rev = commit_file ~path:hello_file ~file_contents:"Hello World!" in
  let mock_rev = Vcs.Mock_revs.to_mock mock_revs ~rev in
  print_s [%sexp (mock_rev : Vcs.Rev.t)];
  [%expect {| 1185512b92d612b25613f2e5b473e5231185512b |}];
  let result =
    let%bind.Or_error () =
      Vcs.Or_error.rename_current_branch vcs ~repo_root ~to_:(Vcs.Branch_name.v "branch")
    in
    Vcs.Or_error.current_branch vcs ~repo_root
  in
  print_s [%sexp (result : Vcs.Branch_name.t Or_error.t)];
  [%expect {| (Ok branch) |}];
  Vcs.rename_current_branch vcs ~repo_root ~to_:Vcs.Branch_name.main;
  let result =
    let%map.Or_error rev = Vcs.Or_error.current_revision vcs ~repo_root in
    Vcs.Mock_revs.to_mock mock_revs ~rev
  in
  print_s [%sexp (result : Vcs.Rev.t Or_error.t)];
  [%expect {| (Ok 1185512b92d612b25613f2e5b473e5231185512b) |}];
  let result = Vcs.Or_error.current_branch vcs ~repo_root in
  print_s [%sexp (result : Vcs.Branch_name.t Or_error.t)];
  [%expect {| (Ok main) |}];
  let show_file_at_rev ~rev ~path =
    Vcs.Or_error.show_file_at_rev vcs ~repo_root ~rev ~path
  in
  let result = show_file_at_rev ~rev ~path:hello_file in
  print_s [%sexp (result : [ `Present of Vcs.File_contents.t | `Absent ] Or_error.t)];
  [%expect {| (Ok (Present "Hello World!")) |}];
  let result = show_file_at_rev ~rev ~path:(Vcs.Path_in_repo.v "absent-file.txt") in
  print_s [%sexp (result : [ `Present of Vcs.File_contents.t | `Absent ] Or_error.t)];
  [%expect {| (Ok Absent) |}];
  let result =
    (* We've characterized here that Git does not distinguish between a file
       absent at a valid revision, and an unknown revision. *)
    show_file_at_rev
      ~rev:(Vcs.Mock_revs.next mock_revs)
      ~path:(Vcs.Path_in_repo.v "absent-file.txt")
  in
  print_s [%sexp (result : [ `Present of Vcs.File_contents.t | `Absent ] Or_error.t)];
  [%expect {| (Ok Absent) |}];
  let result =
    Vcs.Or_error.load_file vcs ~path:(Vcs.Repo_root.append repo_root hello_file)
  in
  print_s [%sexp (result : Vcs.File_contents.t Or_error.t)];
  [%expect {| (Ok "Hello World!") |}];
  let result = Vcs.Or_error.ls_files vcs ~repo_root ~below:Vcs.Path_in_repo.root in
  print_s [%sexp (result : Vcs.Path_in_repo.t list Or_error.t)];
  [%expect {| (Ok (hello.txt)) |}];
  let () =
    (* Below must be an existing directory or [ls_files] returns an error. *)
    match Vcs.Or_error.ls_files vcs ~repo_root ~below:(Vcs.Path_in_repo.v "dir") with
    | Ok _ -> assert false
    | Error e ->
      print_s
        (Vcs_test_helpers.redact_sexp
           (e |> Error.sexp_of_t)
           ~fields:[ "cwd"; "error"; "repo_root" ])
  in
  [%expect
    {|
    ((context (Vcs.ls_files (repo_root <REDACTED>) (below dir))
      ((prog git) (args (ls-files --full-name)) (exit_status Unknown)
       (cwd <REDACTED>) (stdout "") (stderr "")))
     (error <REDACTED>))
    |}];
  let foo_file = Vcs.Path_in_repo.v "foo.txt" in
  let rev2 = commit_file ~path:foo_file ~file_contents:"Hello Foo!" in
  let bar_file = Vcs.Path_in_repo.v "bar.txt" in
  let rev3 = commit_file ~path:bar_file ~file_contents:"Hello Bar!" in
  let rev4 = commit_file ~path:bar_file ~file_contents:"Hello Again Bar!" in
  let result =
    Vcs.Or_error.name_status vcs ~repo_root ~changed:(Between { src = rev2; dst = rev3 })
  in
  print_s [%sexp (result : Vcs.Name_status.t Or_error.t)];
  [%expect {| (Ok ((Added bar.txt))) |}];
  let result =
    Vcs.Or_error.name_status vcs ~repo_root ~changed:(Between { src = rev3; dst = rev4 })
  in
  print_s [%sexp (result : Vcs.Name_status.t Or_error.t)];
  [%expect {| (Ok ((Modified bar.txt))) |}];
  let result =
    Vcs.Or_error.num_status vcs ~repo_root ~changed:(Between { src = rev2; dst = rev3 })
  in
  print_s [%sexp (result : Vcs.Num_status.t Or_error.t)];
  [%expect
    {|
    (Ok
     (((key (One_file bar.txt))
       (num_stat (Num_lines_in_diff ((insertions 1) (deletions 0)))))))
    |}];
  let result =
    Vcs.Or_error.num_status vcs ~repo_root ~changed:(Between { src = rev3; dst = rev4 })
  in
  print_s [%sexp (result : Vcs.Num_status.t Or_error.t)];
  [%expect
    {|
    (Ok
     (((key (One_file bar.txt))
       (num_stat (Num_lines_in_diff ((insertions 1) (deletions 1)))))))
    |}];
  let () =
    match Vcs.Or_error.log vcs ~repo_root with
    | Error _ -> assert false
    | Ok log ->
      (* We traverse the log in reverse order first to assign revisions bottom
         up (this makes it more readable). *)
      ignore (map_sexp [%sexp (List.rev log : Vcs.Log.t)] : Sexp.t);
      print_s (map_sexp [%sexp (log : Vcs.Log.t)])
  in
  [%expect
    {|
    ((Commit (rev rev3) (parent rev2)) (Commit (rev rev2) (parent rev1))
     (Commit (rev rev1) (parent rev0)) (Root (rev rev0)))
    |}];
  let () =
    match Vcs.Or_error.refs vcs ~repo_root with
    | Error _ -> assert false
    | Ok refs -> print_s (map_sexp [%sexp (refs : Vcs.Refs.t)])
  in
  [%expect {| (((rev rev3) (ref_kind (Local_branch (branch_name main))))) |}];
  let () =
    match Vcs.Or_error.graph vcs ~repo_root with
    | Error _ -> assert false
    | Ok graph -> print_s (map_sexp [%sexp (graph : Vcs.Graph.t)])
  in
  [%expect
    {|
    ((nodes
      ((#3 (Commit (rev rev3) (parent #2))) (#2 (Commit (rev rev2) (parent #1)))
       (#1 (Commit (rev rev1) (parent #0))) (#0 (Root (rev rev0)))))
     (revs ((#3 rev3) (#2 rev2) (#1 rev1) (#0 rev0)))
     (refs ((#3 ((Local_branch (branch_name main)))))))
    |}];
  ()
;;
