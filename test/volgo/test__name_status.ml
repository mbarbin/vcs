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

let%expect_test "parse_exn" =
  Eio_main.run
  @@ fun env ->
  let path = Eio.Path.(Eio.Stdenv.fs env / "super-master-mind.name-status") in
  let contents = Eio.Path.load path in
  let lines = String.split_lines contents in
  let name_status = Volgo_git_backend.Name_status.parse_lines_exn ~lines in
  let files_at_src =
    Vcs.Name_status.files_at_src name_status
    |> Set.of_list (module Volgo_base.Vcs.Path_in_repo)
  in
  let files_at_dst =
    Vcs.Name_status.files_at_dst name_status
    |> Set.of_list (module Volgo_base.Vcs.Path_in_repo)
  in
  print_dyn
    (Set.diff files_at_dst files_at_src |> Set.to_list |> Dyn.list Vcs.Path_in_repo.to_dyn);
  [%expect
    {|
    [ "CHANGES.md"
    ; "lib/super_master_mind/src/import/dune"
    ; "lib/super_master_mind/src/import/super_master_mind_import.ml"
    ; "lib/super_master_mind/src/import/super_master_mind_import.mli"
    ]
    |}];
  ()
;;

let%expect_test "files" =
  let lines =
    [ "A\tadded_file"
    ; "D\tremoved_file"
    ; "M\tmodified_file"
    ; "C75\toriginal_copied_file\tnew_copied_file"
    ; "R100\toriginal_renamed_file\tnew_renamed_file"
    ]
  in
  let name_status = Volgo_git_backend.Name_status.parse_lines_exn ~lines in
  print_dyn (name_status |> Vcs.Name_status.to_dyn);
  [%expect
    {|
    [ Added "added_file"
    ; Removed "removed_file"
    ; Modified "modified_file"
    ; Copied
        { src = "original_copied_file"
        ; dst = "new_copied_file"
        ; similarity = 75
        }
    ; Renamed
        { src = "original_renamed_file"
        ; dst = "new_renamed_file"
        ; similarity = 100
        }
    ]
    |}];
  let files = Vcs.Name_status.files name_status in
  print_dyn (files |> Dyn.list Vcs.Path_in_repo.to_dyn);
  [%expect
    {|
    [ "added_file"
    ; "modified_file"
    ; "new_copied_file"
    ; "new_renamed_file"
    ; "original_copied_file"
    ; "original_renamed_file"
    ; "removed_file"
    ]
    |}];
  let files_at_src =
    Vcs.Name_status.files_at_src name_status
    |> Set.of_list (module Volgo_base.Vcs.Path_in_repo)
  in
  print_dyn (files_at_src |> Set.to_list |> Dyn.list Vcs.Path_in_repo.to_dyn);
  [%expect
    {|
    [ "modified_file"
    ; "original_copied_file"
    ; "original_renamed_file"
    ; "removed_file"
    ]
    |}];
  let files_at_dst =
    Vcs.Name_status.files_at_dst name_status
    |> Set.of_list (module Volgo_base.Vcs.Path_in_repo)
  in
  print_dyn (files_at_dst |> Set.to_list |> Dyn.list Vcs.Path_in_repo.to_dyn);
  [%expect {| [ "added_file"; "modified_file"; "new_copied_file"; "new_renamed_file" ] |}];
  print_dyn
    (Set.diff files_at_dst files_at_src |> Set.to_list |> Dyn.list Vcs.Path_in_repo.to_dyn);
  [%expect {| [ "added_file"; "new_copied_file"; "new_renamed_file" ] |}];
  print_dyn
    (Set.diff files_at_src files_at_dst |> Set.to_list |> Dyn.list Vcs.Path_in_repo.to_dyn);
  [%expect {| [ "original_copied_file"; "original_renamed_file"; "removed_file" ] |}];
  ()
;;
