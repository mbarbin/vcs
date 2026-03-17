(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* This test shows a case where [git diff --numstat] doesn't give you numbers
   for insertions and deletions. *)

let%expect_test "num stat without lines" =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Volgo_git_eio.create ~env in
  let repo_root = Vcs_test_helpers.init_temp_repo ~env ~sw ~vcs in
  let commit_file ~path ~file_contents =
    Vcs.save_file
      vcs
      ~path:(Vcs.Repo_root.append repo_root path)
      ~file_contents:(Vcs.File_contents.create file_contents);
    Vcs.add vcs ~repo_root ~path;
    Vcs.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "_")
  in
  let hello_file = Vcs.Path_in_repo.v "hello.txt" in
  let rev1 = commit_file ~path:hello_file ~file_contents:"Hello World!\n" in
  let () =
    match Vcs.show_file_at_rev vcs ~repo_root ~rev:rev1 ~path:hello_file with
    | `Absent -> assert false
    | `Present file_contents -> print_dyn (file_contents |> Vcs.File_contents.to_dyn)
  in
  [%expect
    {|
    "Hello World!\n\
     "
    |}];
  let file1 = Vcs.Path_in_repo.v "file1.txt" in
  let rev2 = commit_file ~path:file1 ~file_contents:"file1" in
  let rev3 =
    commit_file
      ~path:hello_file
      ~file_contents:"Hello World!\nFollowed by an added line\n"
  in
  let rev4 = commit_file ~path:(Vcs.Path_in_repo.v "binary-file") ~file_contents:"\x00" in
  let print_status ~src ~dst =
    let num_status = Vcs.num_status vcs ~repo_root ~changed:(Between { src; dst }) in
    print_dyn (num_status |> Vcs.Num_status.to_dyn)
  in
  print_status ~src:rev1 ~dst:rev2;
  [%expect
    {|
    [ { key = One_file "file1.txt"
      ; num_stat = Num_lines_in_diff { insertions = 1; deletions = 0 }
      }
    ]
    |}];
  print_status ~src:rev2 ~dst:rev3;
  [%expect
    {|
    [ { key = One_file "hello.txt"
      ; num_stat = Num_lines_in_diff { insertions = 1; deletions = 0 }
      }
    ]
    |}];
  print_status ~src:rev3 ~dst:rev4;
  [%expect {| [ { key = One_file "binary-file"; num_stat = Binary_file } ] |}];
  print_status ~src:rev1 ~dst:rev4;
  [%expect
    {|
    [ { key = One_file "binary-file"; num_stat = Binary_file }
    ; { key = One_file "file1.txt"
      ; num_stat = Num_lines_in_diff { insertions = 1; deletions = 0 }
      }
    ; { key = One_file "hello.txt"
      ; num_stat = Num_lines_in_diff { insertions = 1; deletions = 0 }
      }
    ]
    |}];
  ()
;;
