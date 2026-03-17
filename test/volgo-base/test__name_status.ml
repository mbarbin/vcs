(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Vcs = Volgo_base.Vcs

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
  print_dyn (files |> Set.to_list |> Dyn.list Vcs.Path_in_repo.to_dyn);
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
  let files_at_src = Vcs.Name_status.files_at_src name_status in
  print_dyn (files_at_src |> Set.to_list |> Dyn.list Vcs.Path_in_repo.to_dyn);
  [%expect
    {|
    [ "modified_file"
    ; "original_copied_file"
    ; "original_renamed_file"
    ; "removed_file"
    ]
    |}];
  let files_at_dst = Vcs.Name_status.files_at_dst name_status in
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
