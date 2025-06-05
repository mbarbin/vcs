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

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  let current_branch (_ : t) ~repo_root:_ =
    (* CR-soon mbarbin: Due to the current trait architecture we have to define
       both methods as part of this trait implementation. But in fact, I'd like
       to defer on this one, as it involves branches which requires more work.

       I would like to re-consider this trait organization, and probably
       consider splitting it according to what each method is focused on,
       instead of grouping them due to the git command used in their current
       implementation (rev-parse). Once this is done, we can rather *not*
       implement [current_branch] instead of "implementing" with a dynamic
       error. *)
    Error
      (Err.create
         Pp.O.
           [ Pp.text "Branches are not implemented in "
             ++ Pp_tty.kwd (module String) "vcs-hg"
             ++ Pp.text "."
           ])
  ;;

  let current_revision t ~repo_root =
    Runtime.hg
      t
      ~cwd:(repo_root |> Vcs.Repo_root.to_absolute_path)
      ~args:[ "log"; "-r"; "."; "--template"; "{node}" ]
      ~f:(fun output ->
        let open Result.Monad_syntax in
        let* stdout = Vcs.Hg.Result.exit0_and_stdout output in
        match Vcs.Rev.of_string (String.strip stdout) with
        | Ok _ as ok -> ok
        | Error (`Msg m) -> Error (Err.create [ Pp.text m ]) [@coverage off])
  ;;
end
