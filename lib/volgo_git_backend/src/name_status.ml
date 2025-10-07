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

open! Import

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
    [@@deriving_inline sexp_of]

    let sexp_of_t =
      (function
       | `A -> Sexplib0.Sexp.Atom "A"
       | `D -> Sexplib0.Sexp.Atom "D"
       | `M -> Sexplib0.Sexp.Atom "M"
       | `R -> Sexplib0.Sexp.Atom "R"
       | `T -> Sexplib0.Sexp.Atom "T"
       | `C -> Sexplib0.Sexp.Atom "C"
       | `U -> Sexplib0.Sexp.Atom "U"
       | `Q -> Sexplib0.Sexp.Atom "Q"
       | `I -> Sexplib0.Sexp.Atom "I"
       | `Question_mark -> Sexplib0.Sexp.Atom "Question_mark"
       | `Bang -> Sexplib0.Sexp.Atom "Bang"
       | `X -> Sexplib0.Sexp.Atom "X"
       | `Not_supported -> Sexplib0.Sexp.Atom "Not_supported"
       : t -> Sexplib0.Sexp.t)
    ;;

    [@@@deriving.end]
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
        let open Result.Monad_syntax in
        let* stdout = Vcs.Git.Result.exit0_and_stdout output in
        Vcs.Private.try_with (fun () ->
          parse_lines_exn ~lines:(String.split_lines stdout)))
  ;;
end
