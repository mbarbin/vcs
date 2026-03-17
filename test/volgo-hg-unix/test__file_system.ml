(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* Since [Volgo_hg_unix] uses the exact same implementation than
   [Volgo_git_unix] for file system operations, we do not need to test it
   exhaustively. We simply exercise a simple code path. *)

let%expect_test "read_dir" =
  let vcs = Volgo_hg_unix.create () in
  let read_dir dir = print_dyn (Vcs.read_dir vcs ~dir |> Dyn.list Fsegment.to_dyn) in
  let cwd = Unix.getcwd () in
  let dir = Filename.temp_dir ~temp_dir:cwd "vcs_test" "" |> Absolute_path.v in
  let save_file file file_contents =
    Vcs.save_file
      vcs
      ~path:(Absolute_path.extend dir (Fsegment.v file))
      ~file_contents:(Vcs.File_contents.create file_contents)
  in
  read_dir dir;
  [%expect {| [] |}];
  save_file "hello.txt" "Hello World!\n";
  [%expect {||}];
  read_dir dir;
  [%expect {| [ "hello.txt" ] |}];
  ()
;;
