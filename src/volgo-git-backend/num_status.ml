(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Status_code = struct
  module T = struct
    [@@@coverage off]

    type t =
      | Dash
      | Num of int
      | Other of string

    let to_dyn = function
      | Dash -> Dyn.Variant ("Dash", [])
      | Num n -> Dyn.Variant ("Num", [ Dyn.int n ])
      | Other s -> Dyn.Variant ("Other", [ Dyn.string s ])
    ;;

    let sexp_of_t t = Dyn.to_sexp (to_dyn t)
  end

  include T

  let parse = function
    | "-" -> Dash
    | status ->
      (match Int.of_string_opt status with
       | Some n when n >= 0 -> Num n
       | Some _ | None -> Other status)
  ;;
end

let parse_line_exn ~line : Vcs.Num_status.Change.t =
  match
    Vcs.Private.try_with (fun () ->
      match String.split line ~on:'\t' with
      | [] -> assert false
      | [ _ ] | [ _; _ ] | _ :: _ :: _ :: _ :: _ ->
        raise (Err.E (Err.create [ Pp.text "Unexpected output from git diff." ]))
      | [ insertions; deletions; munged_path ] ->
        { Vcs.Num_status.Change.key = Munged_path.parse_exn munged_path
        ; num_stat =
            (match Status_code.parse insertions, Status_code.parse deletions with
             | Dash, Dash -> Binary_file
             | Num insertions, Num deletions ->
               Num_lines_in_diff { insertions; deletions }
             | insertions, deletions ->
               raise
                 (Err.E
                    (Err.create
                       [ Pp.text "Unexpected output from git diff."
                       ; Err.sexp
                           (Sexp.List
                              [ sexp_field (module Status_code) "insertions" insertions
                              ; sexp_field (module Status_code) "deletions" deletions
                              ])
                       ])))
        })
  with
  | Ok t -> t
  | Error err ->
    raise
      (Err.E
         (Err.add_context
            err
            [ Err.sexp
                (Sexp.List
                   [ Sexp.Atom "Volgo_git_backend.Num_status.parse_line_exn"
                   ; sexp_field (module String) "line" line
                   ])
            ]))
;;

let parse_lines_exn ~lines = List.map lines ~f:(fun line -> parse_line_exn ~line)

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  let num_status t ~repo_root ~(changed : Vcs.Name_status.Changed.t) =
    let changed_param =
      match changed with
      | Between { src; dst } ->
        Printf.sprintf "%s..%s" (src |> Vcs.Rev.to_string) (dst |> Vcs.Rev.to_string)
    in
    Runtime.git
      t
      ~cwd:(repo_root |> Vcs.Repo_root.to_absolute_path)
      ~args:[ "diff"; "--numstat"; changed_param ]
      ~f:(fun output ->
        let open Result.Syntax in
        let* stdout = Vcs.Git.Result.exit0_and_stdout output in
        Vcs.Private.try_with (fun () ->
          parse_lines_exn ~lines:(String.split_lines stdout)))
  ;;
end
