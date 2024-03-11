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

type t =
  { mock_revs : Vcs.Mock_revs.t
  ; mutable has_committed : bool
  }

let mock_revs t = t.mock_revs

let create () =
  let mock_revs = Vcs.Mock_revs.create () in
  { mock_revs; has_committed = false }
;;

let commit t ~vcs ~repo_root ~commit_message =
  let%bind rev = Vcs.commit vcs ~repo_root ~commit_message in
  let rev = Vcs.Mock_revs.to_mock t.mock_revs ~rev in
  let%bind () =
    if not t.has_committed
    then (
      t.has_committed <- true;
      Vcs.rename_current_branch vcs ~repo_root ~to_:Vcs.Branch_name.main)
    else return ()
  in
  return rev
;;

let init _ ~vcs ~path =
  let%bind repo_root = Vcs.init vcs ~path in
  let%bind () =
    Vcs.set_user_name vcs ~repo_root ~user_name:(Vcs.User_name.v "Test User")
  in
  let%bind () =
    Vcs.set_user_email vcs ~repo_root ~user_email:(Vcs.User_email.v "test@example.com")
  in
  return repo_root
;;

let rev_parse t ~vcs ~repo_root ~arg =
  let%map rev = Vcs.rev_parse vcs ~repo_root ~arg in
  Vcs.Mock_revs.to_mock t.mock_revs ~rev
;;

let show_file_at_rev t ~vcs ~repo_root ~rev ~path =
  let%bind rev =
    match Vcs.Mock_revs.of_mock t.mock_revs ~mock_rev:rev with
    | Some rev -> return rev
    | None -> Or_error.error_s [%sexp "No such mock revision", { rev : Vcs.Rev.t }]
  in
  Vcs.show_file_at_rev vcs ~repo_root ~rev ~path
;;
