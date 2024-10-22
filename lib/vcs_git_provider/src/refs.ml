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

let parse_ref_kind_exn str : Vcs.Ref_kind.t =
  match
    Vcs.Exn.Private.try_with (fun () ->
      let str =
        match String.chop_prefix str ~prefix:"refs/" with
        | Some str -> str
        | None ->
          raise (Vcs.E (Vcs.Err.error_string "Expected ref to start with 'refs/'"))
      in
      match String.lsplit2 str ~on:'/' with
      | None -> Vcs.Ref_kind.Other { name = str }
      | Some (kind, name) ->
        (match kind with
         | "heads" -> Local_branch { branch_name = Vcs.Branch_name.v name }
         | "remotes" ->
           Remote_branch { remote_branch_name = Vcs.Remote_branch_name.v name }
         | "tags" -> Tag { tag_name = Vcs.Tag_name.v name }
         | _ -> Other { name = str }))
  with
  | Ok t -> t
  | Error err ->
    raise
      (Vcs.E
         (Vcs.Err.add_context
            err
            ~step:
              [%sexp
                "Vcs_git_provider.Refs.parse_ref_kind_exn", { ref_kind = (str : string) }]))
;;

module Dereferenced = struct
  module T = struct
    [@@@coverage off]

    type t =
      { rev : Vcs.Rev.t
      ; ref_kind : Vcs.Ref_kind.t
      ; dereferenced : bool
      }
    [@@deriving sexp_of]

    let equal =
      (fun a__001_ b__002_ ->
         if a__001_ == b__002_
         then true
         else
           Vcs.Rev.equal a__001_.rev b__002_.rev
           && Vcs.Ref_kind.equal a__001_.ref_kind b__002_.ref_kind
           && equal_bool a__001_.dereferenced b__002_.dereferenced
       : t -> t -> bool)
    ;;
  end

  include T

  let parse_exn ~line:str =
    match
      Vcs.Exn.Private.try_with (fun () ->
        match String.lsplit2 str ~on:' ' with
        | None -> raise (Vcs.E (Vcs.Err.error_string "Invalid ref line"))
        | Some (rev, ref_) ->
          (match String.chop_suffix ref_ ~suffix:"^{}" with
           | Some ref_ ->
             { rev = Vcs.Rev.v rev
             ; ref_kind = parse_ref_kind_exn ref_
             ; dereferenced = true
             }
           | None ->
             { rev = Vcs.Rev.v rev
             ; ref_kind = parse_ref_kind_exn ref_
             ; dereferenced = false
             }))
    with
    | Ok t -> t
    | Error err ->
      raise
        (Vcs.E
           (Vcs.Err.add_context
              err
              ~step:
                [%sexp
                  "Vcs_git_provider.Refs.Dereferenced.parse_exn"
                  , { line = (str : string) }]))
  ;;
end

module Ref_kind_table = Vcs.Private.Ref_kind_table

let parse_lines_exn ~lines =
  let lines = List.map lines ~f:(fun line -> Dereferenced.parse_exn ~line) in
  let dereferenced_refs =
    let refs = Ref_kind_table.create (List.length lines) in
    List.iter lines ~f:(fun (line : Dereferenced.t) ->
      if line.dereferenced then Ref_kind_table.add refs ~key:line.ref_kind ~data:());
    refs
  in
  List.filter_map lines ~f:(fun { Dereferenced.rev; ref_kind; dereferenced } ->
    if Ref_kind_table.mem dereferenced_refs ref_kind && not dereferenced
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
        let open Result.Monad_syntax in
        let* output = Vcs.Git.Result.exit0_and_stdout output in
        Vcs.Exn.Private.try_with (fun () ->
          parse_lines_exn ~lines:(String.split_lines output)))
  ;;
end
