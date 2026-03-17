(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module T = struct
  type t = Vcs.Num_status.Key.t =
    | One_file of Vcs.Path_in_repo.t
    | Two_files of
        { src : Vcs.Path_in_repo.t
        ; dst : Vcs.Path_in_repo.t
        }

  let equal = Vcs.Num_status.Key.equal
  let to_dyn = Vcs.Num_status.Key.to_dyn
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
