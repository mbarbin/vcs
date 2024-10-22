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
    Vcs.Exn.Private.try_with (fun () ->
      match Astring.String.cuts ~empty:false ~sep:" => " str with
      | [] -> raise (Vcs.E (Vcs.Err.error_string "Unexpected empty path"))
      | [ str ] ->
        if String.exists str ~f:(function
             | '{' | '}' -> true
             | _ -> false)
        then raise (Vcs.E (Vcs.Err.error_string "Unexpected '{' or '}' in simple path"))
        else One_file (Vcs.Path_in_repo.v str)
      | [ left; right ] ->
        (match String.rsplit2 left ~on:'{' with
         | None ->
           if String.exists str ~f:(function
                | '}' -> true
                | _ -> false)
           then raise (Vcs.E (Vcs.Err.error_string "Matching '{' not found"))
           else
             Two_files { src = Vcs.Path_in_repo.v left; dst = Vcs.Path_in_repo.v right }
         | Some (prefix, left_of_arrow) ->
           let right_of_arrow, suffix =
             match String.lsplit2 right ~on:'}' with
             | Some split -> split
             | None -> raise (Vcs.E (Vcs.Err.error_string "Matching '}' not found"))
           in
           Two_files
             { src = Vcs.Path_in_repo.v (prefix ^ left_of_arrow ^ suffix)
             ; dst = Vcs.Path_in_repo.v (prefix ^ right_of_arrow ^ suffix)
             })
      | _ :: _ :: _ -> raise (Vcs.E (Vcs.Err.error_string "Too many '=>'")))
  with
  | Ok t -> t
  | Error err ->
    raise
      (Vcs.E
         (Vcs.Err.add_context
            err
            ~step:
              [%sexp "Vcs_git_provider.Munged_path.parse_exn", { path = (str : string) }]))
;;
