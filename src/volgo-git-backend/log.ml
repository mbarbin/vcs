(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let parse_log_line_exn ~line:str : Vcs.Log.Line.t =
  match
    Vcs.Private.try_with (fun () ->
      match String.split (String.strip str) ~on:' ' |> List.map ~f:Vcs.Rev.v with
      | [] -> assert false (* [String.split] never returns the empty list. *)
      | rev :: parents -> Vcs.Log.Line.create ~rev ~parents)
  with
  | Ok t -> t
  | Error err ->
    raise
      (Err.E
         (Err.add_context
            err
            [ Err.sexp
                (Sexp.List
                   [ Sexp.Atom "Volgo_git_backend.Log.parse_log_line_exn"
                   ; sexp_field (module String) "line" str
                   ])
            ]))
;;

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  let get_log_lines t ~repo_root =
    Runtime.git
      t
      ~cwd:(repo_root |> Vcs.Repo_root.to_absolute_path)
      ~args:[ "log"; "--all"; "--pretty=format:%H %P" ]
      ~f:(fun output ->
        let open Result.Syntax in
        let* output = Vcs.Git.Result.exit0_and_stdout output in
        Vcs.Private.try_with (fun () ->
          List.map (String.split_lines output) ~f:(fun line -> parse_log_line_exn ~line)))
  ;;
end
