(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Operations                         *)
(*  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
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

let init vcs ~path =
  let repo_root = Vcs.init vcs ~path in
  Vcs.set_user_name vcs ~repo_root ~user_name:(Vcs.User_name.v "Test User");
  Vcs.set_user_email vcs ~repo_root ~user_email:(Vcs.User_email.v "test@example.com");
  repo_root
;;

type 'a env = 'a
  constraint
    'a =
    < fs : [> Eio.Fs.dir_ty ] Eio.Path.t
    ; process_mgr : [> [> `Generic ] Eio.Process.mgr_ty ] Eio.Resource.t
    ; .. >

let init_temp_repo ~env ~sw ~vcs =
  let path = Stdlib.Filename.temp_dir ~temp_dir:(Unix.getcwd ()) "vcs" "test" in
  Eio.Switch.on_release sw (fun () -> Eio.Path.rmtree Eio.Path.(Eio.Stdenv.fs env / path));
  init vcs ~path:(Absolute_path.v path)
;;

let redact_sexp err ~fields =
  let fields =
    List.map fields ~f:(fun fields ->
      match String.split fields ~on:'/' with
      | [] -> assert false [@coverage off]
      | hd :: tl ->
        (* [Nonempty_list] is not in the dependencies of the project at this
           time, so we're using a tuple instead. *)
        hd, tl)
  in
  let rec map sexp ~fields =
    match (sexp : Sexp.t) with
    | Atom _ -> sexp
    | List (Atom atom :: sexps) ->
      let redact = ref false in
      let fields =
        if List.exists fields ~f:(fun (hd, _) -> String.equal hd atom)
        then
          List.filter_map fields ~f:(fun ((hd, tl) as fields) ->
            if String.equal hd atom
            then (
              match tl with
              | [] ->
                redact := true;
                None
              | tl_hd :: tl_tl -> Some (tl_hd, tl_tl))
            else Some fields)
        else fields
      in
      if !redact
      then List [ Atom atom; Atom "<REDACTED>" ]
      else List (Atom atom :: List.map sexps ~f:(fun sexp -> map sexp ~fields))
    | List sexps -> List (List.map sexps ~f:(fun sexp -> map sexp ~fields))
  in
  map err ~fields
;;
