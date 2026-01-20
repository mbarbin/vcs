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

module T = struct
  type t = Vcs.Num_status.Key.t =
    | One_file of Vcs.Path_in_repo.t
    | Two_files of
        { src : Vcs.Path_in_repo.t
        ; dst : Vcs.Path_in_repo.t
        }

  let equal = Vcs.Num_status.Key.equal
  let sexp_of_t = Vcs.Num_status.Key.sexp_of_t
end

include T

let parse_exn str =
  match
    Vcs.Private.try_with (fun () ->
      match Arrow_split.split str with
      | Empty -> raise_notrace (Err.E (Err.create [ Pp.text "Unexpected empty path." ]))
      | More_than_two -> raise_notrace (Err.E (Err.create [ Pp.text "Too many ['=>']." ]))
      | One str ->
        (* Files may contain '{' or '}' characters (e.g., in some templating
           systems). We simply accept them as-is. *)
        One_file (Vcs.Path_in_repo.v str)
      | Two (left, right) ->
        (match String.lsplit2 left ~on:'{' with
         | None ->
           if
             String.exists str ~f:(function
               | '}' -> true
               | _ -> false)
           then raise_notrace (Err.E (Err.create [ Pp.text "Matching '{' not found." ]))
           else
             Two_files { src = Vcs.Path_in_repo.v left; dst = Vcs.Path_in_repo.v right }
         | Some (prefix, left_of_arrow) ->
           let right_of_arrow, suffix =
             match String.rsplit2 right ~on:'}' with
             | Some split -> split
             | None ->
               raise_notrace (Err.E (Err.create [ Pp.text "Matching '}' not found." ]))
           in
           Two_files
             { src = Vcs.Path_in_repo.v (prefix ^ left_of_arrow ^ suffix)
             ; dst = Vcs.Path_in_repo.v (prefix ^ right_of_arrow ^ suffix)
             }))
  with
  | Ok t -> t
  | Error err ->
    raise
      (Err.E
         (Err.add_context
            err
            [ Err.sexp
                (Sexp.List
                   [ Sexp.Atom "Volgo_git_backend.Munged_path.parse_exn"
                   ; sexp_field (module String) "path" str
                   ])
            ]))
;;
