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

let parse_log_line_exn ~line:str : Vcs.Log.Line.t =
  match String.split (String.strip str) ~on:' ' with
  | [ rev ] -> Init { rev = Vcs.Rev.v rev }
  | [ rev; parent ] -> Commit { rev = Vcs.Rev.v rev; parent = Vcs.Rev.v parent }
  | [ rev; parent1; parent2 ] ->
    Merge
      { rev = Vcs.Rev.v rev; parent1 = Vcs.Rev.v parent1; parent2 = Vcs.Rev.v parent2 }
  | [] -> assert false
  | _ :: _ :: _ :: _ -> raise_s [%sexp "Invalid log line", (str : string)]
;;

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  let all t ~repo_root =
    Runtime.git
      t
      ~cwd:(repo_root |> Vcs.Repo_root.to_absolute_path)
      ~args:[ "log"; "--all"; "--pretty=format:%H %P" ]
      ~f:(fun output ->
        let%map output = Vcs.Git.exit0_and_stdout output in
        List.map (String.split_lines output) ~f:(fun line -> parse_log_line_exn ~line))
  ;;
end
