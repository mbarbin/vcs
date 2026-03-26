(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Unix = UnixLabels

let toplevel_exe = "./volgo_toplevel.exe"

let eval ~code =
  let code = String.trim code in
  print_endline "```ocaml";
  print_endline code;
  print_endline "```";
  print_endline "";
  print_endline "```terminal";
  let cmd = toplevel_exe ^ " -noprompt -no-version -color always" in
  let ic, oc, ec = Unix.open_process_full cmd ~env:[||] in
  output_string oc code;
  output_char oc '\n';
  close_out oc;
  let stdout_content = In_channel.input_all ic in
  let stderr_content = In_channel.input_all ec in
  let status = Unix.close_process_full (ic, oc, ec) in
  let stdout_trimmed = String.trim stdout_content in
  if not (String.is_empty stdout_trimmed) then print_endline stdout_trimmed;
  let stderr_trimmed = String.trim stderr_content in
  if not (String.is_empty stderr_trimmed)
  then print_endline stderr_trimmed [@coverage off];
  (match status with
   | WEXITED 0 -> ()
   | _ ->
     (match[@coverage off] status with
      | WEXITED n -> Printf.printf "[%d]\n" n
      | WSIGNALED n -> Printf.printf "[signal %d]\n" n
      | WSTOPPED n -> Printf.printf "[stopped %d]\n" n));
  print_endline "```"
;;
