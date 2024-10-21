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

module Status_code = struct
  module T = struct
    [@@@coverage off]

    type t =
      | Dash
      | Num of int
      | Other of string
    [@@deriving sexp_of]
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
  match String.split line ~on:'\t' with
  | [] -> assert false
  | [ _ ] | [ _; _ ] | _ :: _ :: _ :: _ :: _ ->
    raise_s [%sexp "Unexpected output from git diff", (line : string)]
  | [ insertions; deletions; munged_path ] ->
    { Vcs.Num_status.Change.key = Munged_path.parse_exn munged_path
    ; num_stat =
        (match Status_code.parse insertions, Status_code.parse deletions with
         | Dash, Dash -> Binary_file
         | Num insertions, Num deletions -> Num_lines_in_diff { insertions; deletions }
         | insertions, deletions ->
           raise_s
             [%sexp
               "Unexpected output from git diff"
               , { line : string; insertions : Status_code.t; deletions : Status_code.t }]
           [@coverage off])
    }
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
      ~args:[ "diff"; "--numstat"; changed_param ]
      ~f:(fun output ->
        let open Result.Monad_syntax in
        let* stdout = Vcs.Git.Result.exit0_and_stdout output in
        Vcs.Exn.Private.try_with (fun () ->
          parse_lines_exn ~lines:(String.split_lines stdout)))
  ;;
end
