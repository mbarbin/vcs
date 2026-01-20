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

(* This test shows cases with files with '{' or '}' chars in the names,
   responsible for a limitation of the num-status implementation. Keeping as
   regression tests. *)

module Unix = UnixLabels

let print_raw_numstat vcs ~repo_root ~src ~dst =
  let raw_numstat =
    Vcs.git
      vcs
      ~repo_root
      ~args:
        [ "diff"
        ; "--numstat"
        ; Printf.sprintf "%s..%s" (Vcs.Rev.to_string src) (Vcs.Rev.to_string dst)
        ]
      ~f:Vcs.Git.exit0_and_stdout
  in
  print_endline
    (String.map raw_numstat ~f:(function
       | '\t' -> ' '
       | c -> c))
;;

let%expect_test "files with curly-braces" =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let vcs = Volgo_git_eio.create ~env in
  let repo_root = Vcs_test_helpers.init_temp_repo ~env ~sw ~vcs in
  let save_file ~path ~file_contents =
    Option.iter
      (Vcs.Path_in_repo.to_relative_path path |> Relative_path.parent)
      ~f:(fun dir ->
        let dir = Absolute_path.append (Vcs.Repo_root.to_absolute_path repo_root) dir in
        let dir = Absolute_path.to_string dir in
        if not (Stdlib.Sys.file_exists dir) then Unix.mkdir dir ~perm:0o755);
    Vcs.save_file
      vcs
      ~path:(Vcs.Repo_root.append repo_root path)
      ~file_contents:(Vcs.File_contents.create file_contents)
  in
  let commit_file ~path =
    Vcs.add vcs ~repo_root ~path;
    Vcs.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "_")
  in
  let template_file = Vcs.Path_in_repo.v "template/{{ key }}.txt" in
  save_file ~path:template_file ~file_contents:"Hello World!\n";
  let rev1 = commit_file ~path:template_file in
  print_s
    [%sexp
      (Vcs.show_file_at_rev vcs ~repo_root ~rev:rev1 ~path:template_file
       : [ `Present of Vcs.File_contents.t | `Absent ])];
  [%expect {| (Present "Hello World!\n") |}];
  (* First: changes to the same file. *)
  save_file
    ~path:template_file
    ~file_contents:"Hello Updated Contents!\nHello Added Line!\n";
  let rev2 = commit_file ~path:template_file in
  let print_num_status ~src ~dst =
    let num_status = Vcs.num_status vcs ~repo_root ~changed:(Between { src; dst }) in
    print_s [%sexp (num_status : Vcs.Num_status.t)]
  in
  let print_name_status ~src ~dst =
    let name_status = Vcs.name_status vcs ~repo_root ~changed:(Between { src; dst }) in
    print_s [%sexp (name_status : Vcs.Name_status.t)]
  in
  print_name_status ~src:rev1 ~dst:rev2;
  [%expect {| ((Modified "template/{{ key }}.txt")) |}];
  print_num_status ~src:rev1 ~dst:rev2;
  [%expect
    {|
    (((key (One_file "template/{{ key }}.txt"))
      (num_stat (Num_lines_in_diff (insertions 2) (deletions 1)))))
    |}];
  let renamed_file1 = Vcs.Path_in_repo.v "template/no-braces.txt" in
  (* Next let's do some renames and make sure the munged paths are properly handled. *)
  Vcs.git
    vcs
    ~repo_root
    ~args:
      [ "mv"
      ; Vcs.Path_in_repo.to_string template_file
      ; Vcs.Path_in_repo.to_string renamed_file1
      ]
    ~f:Vcs.Git.exit0;
  let rev3 = Vcs.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "Rename1") in
  print_name_status ~src:rev2 ~dst:rev3;
  [%expect
    {|
    ((Renamed (src "template/{{ key }}.txt") (dst template/no-braces.txt)
      (similarity 100)))
    |}];
  print_raw_numstat vcs ~repo_root ~src:rev2 ~dst:rev3;
  [%expect {| 0 0 template/{{{ key }}.txt => no-braces.txt} |}];
  print_num_status ~src:rev2 ~dst:rev3;
  [%expect
    {|
    (((key
       (Two_files (src "template/{{ key }}.txt") (dst template/no-braces.txt)))
      (num_stat (Num_lines_in_diff (insertions 0) (deletions 0)))))
    |}];
  let renamed_file2 = Vcs.Path_in_repo.v "template/hello-{{ mix }}-FOO.{{ ext }}" in
  let renamed_file3 = Vcs.Path_in_repo.v "template/hello-{{ mix }}-BAR.{{ ext }}" in
  Vcs.git
    vcs
    ~repo_root
    ~args:
      [ "mv"
      ; Vcs.Path_in_repo.to_string renamed_file1
      ; Vcs.Path_in_repo.to_string renamed_file2
      ]
    ~f:Vcs.Git.exit0;
  let rev4 = Vcs.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "Rename2") in
  print_name_status ~src:rev3 ~dst:rev4;
  [%expect
    {|
    ((Renamed (src template/no-braces.txt)
      (dst "template/hello-{{ mix }}-FOO.{{ ext }}") (similarity 100)))
    |}];
  print_raw_numstat vcs ~repo_root ~src:rev3 ~dst:rev4;
  [%expect {| 0 0 template/{no-braces.txt => hello-{{ mix }}-FOO.{{ ext }}} |}];
  print_num_status ~src:rev3 ~dst:rev4;
  [%expect
    {|
    (((key
       (Two_files (src template/no-braces.txt)
        (dst "template/hello-{{ mix }}-FOO.{{ ext }}")))
      (num_stat (Num_lines_in_diff (insertions 0) (deletions 0)))))
    |}];
  (* More complex case with rename part in the middle. *)
  Vcs.git
    vcs
    ~repo_root
    ~args:
      [ "mv"
      ; Vcs.Path_in_repo.to_string renamed_file2
      ; Vcs.Path_in_repo.to_string renamed_file3
      ]
    ~f:Vcs.Git.exit0;
  let rev5 = Vcs.commit vcs ~repo_root ~commit_message:(Vcs.Commit_message.v "Rename3") in
  print_name_status ~src:rev4 ~dst:rev5;
  [%expect
    {|
    ((Renamed (src "template/hello-{{ mix }}-FOO.{{ ext }}")
      (dst "template/hello-{{ mix }}-BAR.{{ ext }}") (similarity 100)))
    |}];
  print_raw_numstat vcs ~repo_root ~src:rev4 ~dst:rev5;
  [%expect
    {| 0 0 template/{hello-{{ mix }}-FOO.{{ ext }} => hello-{{ mix }}-BAR.{{ ext }}} |}];
  print_num_status ~src:rev4 ~dst:rev5;
  [%expect
    {|
    (((key
       (Two_files (src "template/hello-{{ mix }}-FOO.{{ ext }}")
        (dst "template/hello-{{ mix }}-BAR.{{ ext }}")))
      (num_stat (Num_lines_in_diff (insertions 0) (deletions 0)))))
    |}];
  ()
;;
