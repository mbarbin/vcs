(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module Diff_status = struct
  module T = struct
    [@@@coverage off]

    type t =
      [ `A
      | `D
      | `M
      | `R
      | `T
      | `C
      | `U
      | `Q
      | `I
      | `Question_mark
      | `Bang
      | `X
      | `Not_supported
      ]

    let to_dyn = function
      | `A -> Dyn.Variant ("A", [])
      | `D -> Dyn.Variant ("D", [])
      | `M -> Dyn.Variant ("M", [])
      | `R -> Dyn.Variant ("R", [])
      | `T -> Dyn.Variant ("T", [])
      | `C -> Dyn.Variant ("C", [])
      | `U -> Dyn.Variant ("U", [])
      | `Q -> Dyn.Variant ("Q", [])
      | `I -> Dyn.Variant ("I", [])
      | `Question_mark -> Dyn.Variant ("Question_mark", [])
      | `Bang -> Dyn.Variant ("Bang", [])
      | `X -> Dyn.Variant ("X", [])
      | `Not_supported -> Dyn.Variant ("Not_supported", [])
    ;;

    let sexp_of_t t = Dyn.to_sexp (to_dyn t)
  end

  include T

  let parse_exn str : t =
    if String.is_empty str
    then raise (Err.E (Err.create [ Pp.text "Unexpected empty diff status." ]));
    match str.[0] with
    | 'A' -> `A
    | 'D' -> `D
    | 'M' -> `M
    | 'U' -> `U
    | 'Q' -> `Q
    | 'I' -> `I
    | '?' -> `Question_mark
    | '!' -> `Bang
    | 'X' -> `X
    | 'R' -> `R
    | 'T' -> `T
    | 'C' -> `C
    | _ -> `Not_supported
  ;;
end

let parse_line_exn ~line : Vcs.Name_status.Change.t =
  match
    Vcs.Private.try_with (fun () ->
      match String.split line ~on:'\t' with
      | [] -> assert false
      | [ _ ] ->
        raise (Err.E (Err.create [ Pp.text "Unexpected output from git status." ]))
      | status :: path :: rest ->
        (match Diff_status.parse_exn status with
         | `A -> Vcs.Name_status.Change.Added (Vcs.Path_in_repo.v path)
         | `D -> Removed (Vcs.Path_in_repo.v path)
         | `M | `T -> Modified (Vcs.Path_in_repo.v path)
         | (`R | `C) as diff_status ->
           let similarity =
             let data = String.sub status ~pos:1 ~len:(String.length status - 1) in
             match Int.of_string_opt data with
             | Some i -> i
             | None ->
               raise
                 (Err.E
                    (Err.create
                       [ Pp.textf
                           "Git diff status '%s' expected to be followed by an integer."
                           (Diff_status.sexp_of_t diff_status |> Sexp.to_string_hum)
                       ; Pp.textf "Data parsed was %S (not an int)." data
                       ]))
           in
           let path2 =
             match List.hd rest with
             | Some hd -> Vcs.Path_in_repo.v hd
             | None ->
               raise (Err.E (Err.create [ Pp.text "Unexpected output from git status." ]))
           in
           (match diff_status with
            | `R -> Renamed { src = Vcs.Path_in_repo.v path; dst = path2; similarity }
            | `C -> Copied { src = Vcs.Path_in_repo.v path; dst = path2; similarity })
         | other ->
           raise
             (Err.E
                (Err.create
                   [ Pp.text "Unexpected status:"
                   ; Err.sexp
                       (Sexp.List
                          [ sexp_field (module String) "status" status
                          ; sexp_field (module Diff_status) "other" other
                          ])
                   ]))))
  with
  | Ok t -> t
  | Error err ->
    raise
      (Err.E
         (Err.add_context
            err
            [ Err.sexp
                (Sexp.List
                   [ Sexp.Atom "Volgo_git_backend.Name_status.parse_line_exn"
                   ; sexp_field (module String) "line" line
                   ])
            ]))
;;

let parse_lines_exn ~lines = List.map lines ~f:(fun line -> parse_line_exn ~line)

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  let name_status t ~repo_root ~(changed : Vcs.Name_status.Changed.t) =
    let changed_param =
      match changed with
      | Between { src; dst } ->
        Printf.sprintf "%s..%s" (src |> Vcs.Rev.to_string) (dst |> Vcs.Rev.to_string)
    in
    Runtime.git
      t
      ~cwd:(repo_root |> Vcs.Repo_root.to_absolute_path)
      ~args:[ "diff"; "--name-status"; changed_param ]
      ~f:(fun output ->
        let open Result.Syntax in
        let* stdout = Vcs.Git.Result.exit0_and_stdout output in
        Vcs.Private.try_with (fun () ->
          parse_lines_exn ~lines:(String.split_lines stdout)))
  ;;
end
