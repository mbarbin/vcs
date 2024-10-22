(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024 Mathieu Barbin <mathieu.barbin@gmail.com>               *)
(*                                                                             *)
(*  This file is part of Vcs.                                                  *)
(*                                                                             *)
(*  Vcs is free software; you can redistribute it and/or modify it under       *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Vcs is distributed in the hope that it will be useful, but WITHOUT ANY     *)
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
      | `C
      | `U
      | `Q
      | `I
      | `Question_mark
      | `Bang
      | `X
      | `Not_supported
      ]
    [@@deriving sexp_of]
  end

  include T

  let parse_exn str : t =
    if String.is_empty str
    then raise (Vcs.E (Vcs.Err.error_string "Unexpected empty diff status"));
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
    | 'C' -> `C
    | _ -> `Not_supported
  ;;
end

let parse_line_exn ~line : Vcs.Name_status.Change.t =
  match
    Vcs.Exn.Private.try_with (fun () ->
      match String.split line ~on:'\t' with
      | [] -> assert false
      | [ _ ] -> raise (Vcs.E (Vcs.Err.error_string "Unexpected output from git status"))
      | status :: path :: rest ->
        (match Diff_status.parse_exn status with
         | `A -> Vcs.Name_status.Change.Added (Vcs.Path_in_repo.v path)
         | `D -> Removed (Vcs.Path_in_repo.v path)
         | `M -> Modified (Vcs.Path_in_repo.v path)
         | (`R | `C) as diff_status ->
           let similarity =
             String.sub status ~pos:1 ~len:(String.length status - 1) |> Int.of_string
           in
           let path2 =
             match List.hd rest with
             | Some hd -> Vcs.Path_in_repo.v hd
             | None ->
               raise (Vcs.E (Vcs.Err.error_string "Unexpected output from git status"))
           in
           (match diff_status with
            | `R -> Renamed { src = Vcs.Path_in_repo.v path; dst = path2; similarity }
            | `C -> Copied { src = Vcs.Path_in_repo.v path; dst = path2; similarity })
         | other ->
           raise
             (Vcs.E
                (Vcs.Err.create_s
                   [%sexp "Unexpected status", (status : string), (other : Diff_status.t)]))))
  with
  | Ok t -> t
  | Error err ->
    raise
      (Vcs.E
         (Vcs.Err.add_context
            err
            ~step:[%sexp "Vcs_git_provider.Name_status.parse_line_exn", { line : string }]))
;;

let parse_lines_exn ~lines = List.map lines ~f:(fun line -> parse_line_exn ~line)

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  let diff t ~repo_root ~(changed : Vcs.Name_status.Changed.t) =
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
        Vcs.Exn.Private.try_with (fun () ->
          parse_lines_exn ~lines:(String.split_lines stdout)))
  ;;
end
