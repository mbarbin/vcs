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

let parse_log_line_exn ~line:str : Vcs.Log.Line.t =
  match
    Vcs.Private.try_with (fun () ->
      match String.split (String.strip str) ~on:' ' with
      | [] -> assert false (* [String.split] never returns the empty list. *)
      | [ rev ] -> Vcs.Log.Line.Root { rev = Vcs.Rev.v rev }
      | [ rev; parent ] -> Commit { rev = Vcs.Rev.v rev; parent = Vcs.Rev.v parent }
      | [ rev; parent1; parent2 ] ->
        Merge
          { rev = Vcs.Rev.v rev
          ; parent1 = Vcs.Rev.v parent1
          ; parent2 = Vcs.Rev.v parent2
          }
      | _ :: _ :: _ :: _ ->
        raise (Err.E (Err.create [ Pp.text "Too many words (expected 1, 2, or 3)." ])))
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
        let open Result.Monad_syntax in
        let* output = Vcs.Git.Result.exit0_and_stdout output in
        Vcs.Private.try_with (fun () ->
          List.map (String.split_lines output) ~f:(fun line -> parse_log_line_exn ~line)))
  ;;
end
