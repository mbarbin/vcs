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

module Top = struct
  module Git = Git
end

open! Import
module Add = Trait_add
module Branch = Trait_branch
module Commit = Trait_commit
module Config = Trait_config
module File_system = Trait_file_system
module Git = Trait_git
module Init = Trait_init
module Log = Trait_log
module Ls_files = Trait_ls_files
module Name_status = Trait_name_status
module Num_status = Trait_num_status
module Refs = Trait_refs
module Rev_parse = Trait_rev_parse
module Show = Trait_show

class type add = Add.t
class type branch = Branch.t
class type commit = Commit.t
class type config = Config.t
class type file_system = File_system.t
class type git = Git.t
class type init = Init.t
class type log = Log.t
class type ls_files = Ls_files.t
class type name_status = Name_status.t
class type num_status = Num_status.t
class type refs = Refs.t
class type rev_parse = Rev_parse.t
class type show = Show.t

class type t = object
  inherit add
  inherit branch
  inherit commit
  inherit config
  inherit file_system
  inherit git
  inherit init
  inherit log
  inherit ls_files
  inherit name_status
  inherit num_status
  inherit refs
  inherit rev_parse
  inherit show
end

class unimplemented : t =
  (* When used through the vcs interface, the context for each method is already
     part of the full error trace. This includes the [repo_root] and/or whatever
     useful arguments for each of the methods in the error messages. We do not
     want to include them here too, as they would simply be printed twice. *)
  let unimplemented ~trait ~method_ =
    Error
      (Err.create
         Pp.O.
           [ Pp.text "Trait "
             ++ Pp_tty.id (module String) trait
             ++ Pp.text " method "
             ++ Pp_tty.id (module String) method_
             ++ Pp.text " is not available in this repository."
           ])
  in
  object
    (* add *)

    method add ~repo_root:_ ~path:_ = unimplemented ~trait:"Vcs.Trait.add" ~method_:"add"

    (* branch *)

    method rename_current_branch ~repo_root:_ ~to_:_ =
      unimplemented ~trait:"Vcs.Trait.branch" ~method_:"rename_current_branch"

    (* commit *)

    method commit ~repo_root:_ ~commit_message:_ =
      unimplemented ~trait:"Vcs.Trait.commit" ~method_:"commit"

    (* config *)

    method set_user_name ~repo_root:_ ~user_name:_ =
      unimplemented ~trait:"Vcs.Trait.config" ~method_:"set_user_name"

    method set_user_email ~repo_root:_ ~user_email:_ =
      unimplemented ~trait:"Vcs.Trait.config" ~method_:"set_user_email"

    (* file_system *)

    method load_file ~path:_ =
      unimplemented ~trait:"Vcs.Trait.file_system" ~method_:"load_file"

    method save_file ?perms:_ () ~path:_ ~file_contents:_ =
      unimplemented ~trait:"Vcs.Trait.file_system" ~method_:"save_file"

    method read_dir ~dir:_ =
      unimplemented ~trait:"Vcs.Trait.file_system" ~method_:"read_dir"

    (* git *)

    method git
      :  'a.
         ?env:string array
      -> unit
      -> cwd:Absolute_path.t
      -> args:string list
      -> f:(Top.Git.Output.t -> ('a, Err.t) Result.t)
      -> ('a, Err.t) Result.t =
      fun ?env:_ () ~cwd:_ ~args:_ ~f:_ ->
        unimplemented ~trait:"Vcs.Trait.git" ~method_:"git"

    (* init *)

    method init ~path:_ = unimplemented ~trait:"Vcs.Trait.init" ~method_:"init"

    (* log *)

    method all ~repo_root:_ = unimplemented ~trait:"Vcs.Trait.log" ~method_:"all"

    (* ls_files *)

    method ls_files ~repo_root:_ ~below:_ =
      unimplemented ~trait:"Vcs.Trait.ls_files" ~method_:"ls_files"

    (* name_status *)

    method name_status ~repo_root:_ ~changed:_ =
      unimplemented ~trait:"Vcs.Trait.name_status" ~method_:"name_status"

    (* num_status *)

    method num_status ~repo_root:_ ~changed:_ =
      unimplemented ~trait:"Vcs.Trait.num_status" ~method_:"num_status"

    (* refs *)

    method show_ref ~repo_root:_ =
      unimplemented ~trait:"Vcs.Trait.refs" ~method_:"show_ref"

    (* rev_parse *)

    method current_branch ~repo_root:_ =
      unimplemented ~trait:"Vcs.Trait.rev_parse" ~method_:"current_branch"

    method current_revision ~repo_root:_ =
      unimplemented ~trait:"Vcs.Trait.rev_parse" ~method_:"current_revision"

    (* show *)

    method show_file_at_rev ~repo_root:_ ~rev:_ ~path:_ =
      unimplemented ~trait:"Vcs.Trait.show" ~method_:"show_file_at_rev"
  end
