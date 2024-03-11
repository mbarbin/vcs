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

module Dereferenced = struct
  type t =
    { rev : Vcs.Rev.t
    ; ref_kind : Vcs.Ref_kind.t
    ; dereferenced : bool
    }
  [@@deriving equal, sexp_of]

  let parse_ref_kind_exn str : Vcs.Ref_kind.t =
    let str = String.chop_prefix_exn str ~prefix:"refs/" in
    match String.lsplit2 str ~on:'/' with
    | None -> Other { name = str }
    | Some (kind, name) ->
      (match kind with
       | "heads" -> Local_branch { branch_name = Vcs.Branch_name.v name }
       | "remotes" -> Remote_branch { remote_branch_name = Vcs.Remote_branch_name.v name }
       | "tags" -> Tag { tag_name = Vcs.Tag_name.v name }
       | _ -> Other { name = str })
  ;;

  let parse_exn ~line:str =
    match String.lsplit2 str ~on:' ' with
    | None -> raise_s [%sexp "Invalid ref line", (str : string)]
    | Some (rev, ref_) ->
      (match String.chop_suffix ref_ ~suffix:"^{}" with
       | Some ref_ ->
         { rev = Vcs.Rev.v rev; ref_kind = parse_ref_kind_exn ref_; dereferenced = true }
       | None ->
         { rev = Vcs.Rev.v rev; ref_kind = parse_ref_kind_exn ref_; dereferenced = false })
  ;;
end

let parse_lines_exn ~lines =
  let lines = List.map lines ~f:(fun line -> Dereferenced.parse_exn ~line) in
  let dereferenced_refs =
    let refs = Hash_set.create (module Vcs.Ref_kind) in
    List.iter lines ~f:(fun line ->
      if line.dereferenced then Hash_set.add refs line.ref_kind);
    refs
  in
  List.filter_map lines ~f:(fun { Dereferenced.rev; ref_kind; dereferenced } ->
    if Hash_set.mem dereferenced_refs ref_kind && not dereferenced
    then None
    else Some { Vcs.Refs.Line.rev; ref_kind })
;;

module Make (Runtime : Runtime.S) = struct
  type t = Runtime.t

  let show_ref t ~repo_root =
    Runtime.git
      t
      ~cwd:(repo_root |> Vcs.Repo_root.to_absolute_path)
      ~args:[ "show-ref"; "--dereference" ]
      ~f:(fun output ->
        let%map output = Vcs.Git.exit0_and_stdout output in
        parse_lines_exn ~lines:(String.split_lines output))
  ;;
end
