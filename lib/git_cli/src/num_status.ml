(*******************************************************************************)
(*  Vcs - a versatile OCaml library for Git interaction                        *)
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

let parse_line_exn ~line : Vcs.Num_status.Change.t =
  match String.split line ~on:'\t' with
  | [] -> assert false
  | [ _ ] | [ _; _ ] | _ :: _ :: _ :: _ :: _ ->
    raise_s [%sexp "Unexpected output from git diff", (line : string)]
  | [ insertions; deletions; munged_path ] ->
    { Vcs.Num_status.Change.key = Munged_path.parse_exn munged_path
    ; num_lines_in_diff =
        { insertions = Int.of_string insertions; deletions = Int.of_string deletions }
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
        let%bind stdout = Vcs.Git.exit0_and_stdout output in
        Or_error.try_with (fun () -> parse_lines_exn ~lines:(String.split_lines stdout)))
  ;;
end
