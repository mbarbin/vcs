(*******************************************************************************)
(*  Vcs - a Versatile OCaml Library for Git Interaction                        *)
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

module Config = struct
  (* This is boilerplate code to be used when we'll have things to select, such
     as several backends, or backend modifiers. *)
  type t = { unit : unit }

  let silence_w69_unused_field t =
    ignore (t.unit : unit);
    ()
  ;;

  let default = { unit = () }

  let arg =
    let%map_open.Command () = Arg.return () in
    let t = { unit = () } in
    silence_w69_unused_field t;
    t
  ;;
end

module Create_vcs_backend = struct
  let repo_root (dir : _ Eio.Path.t) =
    dir
    |> snd
    |> Absolute_path.of_string
    |> Or_error.ok_exn
    |> Vcs.Repo_root.of_absolute_path
  ;;

  let from_cwd ~env ~cwd ~config:_ =
    let fs = Eio.Stdenv.fs env in
    match
      With_return.with_return_option (fun { return } ->
        let rec visit dir =
          List.iter (Eio.Path.read_dir dir) ~f:(fun entry ->
            match entry with
            | ".git" ->
              (* We don't check whether [".git"] is a directory, because this
                 breaks for git worktrees. Indeed, the file [".git"] at the root
                 of a repository created with [git worktree add] is a regular
                 file. *)
              return (`Git, dir)
            | _ -> ());
          match Eio.Path.split dir with
          | None -> ()
          | Some (parent_dir, _) -> visit parent_dir
        in
        visit Eio.Path.(fs / (cwd |> Absolute_path.to_string)))
    with
    | None -> None
    | Some ((`Git as vcs), dir) ->
      let vcs =
        match vcs with
        | `Git -> Vcs_git.create ~env
      in
      let repo_root = repo_root dir in
      Some (vcs, repo_root)
  ;;
end

module Context = struct
  type t =
    { config : Config.t
    ; fs : Eio.Fs.dir_ty Eio.Path.t
    ; cwd : Absolute_path.t
    ; vcs : Vcs_git.t'
    ; repo_root : Vcs.Repo_root.t
    }

  let silence_w69_unused_field t =
    ignore (t.config : Config.t);
    ignore (t.fs : Eio.Fs.dir_ty Eio.Path.t);
    ()
  ;;

  let create ?cwd ~env ~config () =
    let cwd =
      match cwd with
      | Some cwd -> cwd
      | None -> Unix.getcwd () |> Absolute_path.v
    in
    let%bind vcs, repo_root =
      match Create_vcs_backend.from_cwd ~env ~cwd ~config with
      | Some x -> Ok x
      | None -> Or_error.error_string "Not in a supported version control repo"
    in
    let t =
      { config
      ; fs = (Eio.Stdenv.fs env :> Eio.Fs.dir_ty Eio.Path.t)
      ; cwd
      ; vcs
      ; repo_root
      }
    in
    silence_w69_unused_field t;
    return t
  ;;
end

module Initialized = struct
  type t =
    { vcs : Vcs_git.t'
    ; repo_root : Vcs.Repo_root.t
    ; context : Context.t
    }
end

let initialize ~env ~config =
  let%bind c = Context.create ~env ~config () in
  return { Initialized.vcs = c.vcs; repo_root = c.repo_root; context = c }
;;

type 'a t = Context.t -> 'a Or_error.t

let resolve t ~context = t context

let pos_branch_name ~pos ~doc =
  let%map_open.Command branch_name =
    Arg.pos ~pos (Param.validated_string (module Vcs.Branch_name)) ~docv:"branch" ~doc
  in
  branch_name
;;

let pos_branch_name_opt ~pos ~doc =
  let%map_open.Command branch_name =
    Arg.pos_opt ~pos (Param.validated_string (module Vcs.Branch_name)) ~docv:"branch" ~doc
  in
  branch_name
;;

let pos_path ~pos ~doc =
  let%map_open.Command path =
    Arg.pos ~pos (Param.validated_string (module Fpath)) ~docv:"file" ~doc
  in
  fun (c : Context.t) ->
    Or_error.try_with (fun () -> Absolute_path.relativize ~root:c.cwd path)
;;

let pos_path_in_repo ~pos ~doc =
  let%map_open.Command path =
    Arg.pos ~pos (Param.validated_string (module Fpath)) ~docv:"file" ~doc
  in
  fun (c : Context.t) ->
    let repo_root = Vcs.Repo_root.to_absolute_path c.repo_root in
    Or_error.try_with_join (fun () ->
      let path = Absolute_path.relativize ~root:c.cwd path in
      let%bind relative_path = Absolute_path.chop_prefix ~prefix:repo_root path in
      return (Vcs.Path_in_repo.of_relative_path relative_path))
;;

let pos_rev ~pos ~doc =
  let%map_open.Command rev =
    Arg.pos ~pos (Param.validated_string (module Vcs.Rev)) ~docv:"rev" ~doc
  in
  rev
;;

let pos_revs ~doc =
  let%map_open.Command revs =
    Arg.pos_all (Param.validated_string (module Vcs.Rev)) ~docv:"rev" ~doc
  in
  revs
;;

let below_path_in_repo =
  let%map_open.Command path =
    Arg.named_opt
      [ "below" ]
      (Param.validated_string (module Fpath))
      ~docv:"PATH"
      ~doc:"only below path"
  in
  fun (c : Context.t) ->
    let repo_root = Vcs.Repo_root.to_absolute_path c.repo_root in
    Or_error.try_with_join (fun () ->
      match path with
      | None -> return None
      | Some path ->
        let path = Absolute_path.relativize ~root:c.cwd path in
        let%bind relative_path = Absolute_path.chop_prefix ~prefix:repo_root path in
        return (Some (Vcs.Path_in_repo.of_relative_path relative_path)))
;;

let commit_message =
  let%map_open.Command commit_message =
    Arg.named
      [ "message"; "m" ]
      (Param.validated_string (module Vcs.Commit_message))
      ~docv:"MSG"
      ~doc:"commit message"
  in
  commit_message
;;

let quiet =
  let%map_open.Command quiet =
    Arg.flag [ "quiet"; "q" ] ~doc:"suppress output on success"
  in
  quiet
;;

let rev ~doc =
  let%map_open.Command rev =
    Arg.named [ "rev"; "r" ] (Param.validated_string (module Vcs.Rev)) ~docv:"REV" ~doc
  in
  rev
;;

let user_name =
  let%map_open.Command user_name =
    Arg.named
      [ "user.name" ]
      (Param.validated_string (module Vcs.User_name))
      ~docv:"USER"
      ~doc:"user name"
  in
  user_name
;;

let user_email =
  let%map_open.Command user_email =
    Arg.named
      [ "user.email" ]
      (Param.validated_string (module Vcs.User_email))
      ~docv:"EMAIL"
      ~doc:"user email"
  in
  user_email
;;
