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

module Vcs_kind = struct
  [@@@coverage off]

  type t =
    | Git
    | Hg
  [@@deriving enumerate, sexp_of]

  let compare = (Stdlib.compare : t -> t -> int)
  let equal = (( = ) : t -> t -> bool)

  [@@@coverage on]

  let seeded_hash = (Hashtbl.seeded_hash : int -> t -> int)
  let hash = (Hashtbl.hash : t -> int)
end

type t =
  { platform : Platform.t
  ; vcs_kind : Vcs_kind.t
  ; user_handle : User_handle.t
  ; repo_name : Repo_name.t
  }
[@@deriving sexp_of]

let compare = (Stdlib.compare : t -> t -> int)
let equal = (( = ) : t -> t -> bool)
let seeded_hash = (Hashtbl.seeded_hash : int -> t -> int)
let hash = (Hashtbl.hash : t -> int)

module Protocol = struct
  [@@@coverage off]

  type t =
    | Ssh
    | Https
  [@@deriving enumerate, sexp_of]

  let compare = (Stdlib.compare : t -> t -> int)
  let equal = (( = ) : t -> t -> bool)

  [@@@coverage on]

  let seeded_hash = (Hashtbl.seeded_hash : int -> t -> int)
  let hash = (Hashtbl.hash : t -> int)
end

module Ssh_syntax = struct
  type t =
    | Scp_like
    | Url_style
  [@@deriving enumerate, sexp_of]

  let compare = (Stdlib.compare : t -> t -> int)
  let equal = (( = ) : t -> t -> bool)
  let seeded_hash = (Hashtbl.seeded_hash : int -> t -> int)
  let hash = (Hashtbl.hash : t -> int)

  let used_by_default_on_platform ~platform =
    match (platform : Platform.t) with
    | Bitbucket | Codeberg -> Url_style
    | GitHub | GitLab | Sourcehut -> Scp_like
  ;;
end

module Url = struct
  type t =
    { platform : Platform.t
    ; vcs_kind : Vcs_kind.t
    ; user_handle : User_handle.t
    ; repo_name : Repo_name.t
    ; protocol : Protocol.t
    }
  [@@deriving sexp_of]

  let compare = (Stdlib.compare : t -> t -> int)
  let equal = (( = ) : t -> t -> bool)
  let seeded_hash = (Hashtbl.seeded_hash : int -> t -> int)
  let hash = (Hashtbl.hash : t -> int)

  let domain ~(platform : Platform.t) ~(vcs_kind : Vcs_kind.t) =
    match platform with
    | Bitbucket -> "bitbucket.org"
    | Codeberg -> "codeberg.org"
    | GitHub -> "github.com"
    | GitLab -> "gitlab.com"
    | Sourcehut ->
      (match vcs_kind with
       | Git -> "git.sr.ht"
       | Hg -> "hg.sr.ht")
  ;;

  let prefix_to_string
        ~(platform : Platform.t)
        ~(vcs_kind : Vcs_kind.t)
        ~(protocol : Protocol.t)
        ~(ssh_syntax : Ssh_syntax.t)
    =
    match protocol with
    | Https -> Printf.sprintf "https://%s/" (domain ~platform ~vcs_kind)
    | Ssh ->
      let user =
        match vcs_kind with
        | Git -> "git"
        | Hg -> "hg"
      in
      let user_at = user ^ "@" ^ domain ~platform ~vcs_kind in
      (match ssh_syntax with
       | Scp_like -> user_at ^ ":"
       | Url_style -> "ssh://" ^ user_at ^ "/")
  ;;

  let user_namespace ~user_handle ~platform =
    let user_handle = User_handle.to_string user_handle in
    match (platform : Platform.t) with
    | Bitbucket | Codeberg | GitHub | GitLab -> user_handle
    | Sourcehut -> "~" ^ user_handle
  ;;

  let url_repo_basename ~repo_name ~(vcs_kind : Vcs_kind.t) =
    let repo = Repo_name.to_string repo_name in
    let suffix =
      match vcs_kind with
      | Git -> ".git"
      | Hg -> ""
    in
    repo ^ suffix
  ;;

  let to_string t ~ssh_syntax =
    let { platform; vcs_kind; user_handle; repo_name; protocol } = t in
    let prefix = prefix_to_string ~platform ~vcs_kind ~protocol ~ssh_syntax in
    let user_namespace = user_namespace ~user_handle ~platform in
    let url_repo_basename = url_repo_basename ~repo_name ~vcs_kind in
    Printf.sprintf "%s%s/%s" prefix user_namespace url_repo_basename
  ;;

  let to_url_string t = to_string t ~ssh_syntax:Url_style

  let to_platform_string t =
    to_string t ~ssh_syntax:(Ssh_syntax.used_by_default_on_platform ~platform:t.platform)
  ;;

  let of_string (s : string) : (t, [ `Msg of string ]) Result.t =
    let open Result.Monad_syntax in
    let starts_with_ssh = String.starts_with s ~prefix:"ssh://" in
    let protocols =
      if String.starts_with s ~prefix:"https://"
      then [ Protocol.Https ]
      else if starts_with_ssh
      then [ Protocol.Ssh ]
      else Protocol.all
    in
    let platforms = Platform.all in
    let vcs_kinds = Vcs_kind.all in
    let ssh_syntaxes =
      if starts_with_ssh then [ Ssh_syntax.Url_style ] else [ Ssh_syntax.Scp_like ]
    in
    match
      List.find_map platforms ~f:(fun platform ->
        List.find_map vcs_kinds ~f:(fun vcs_kind ->
          List.find_map protocols ~f:(fun protocol ->
            List.find_map ssh_syntaxes ~f:(fun ssh_syntax ->
              let prefix = prefix_to_string ~platform ~vcs_kind ~protocol ~ssh_syntax in
              Option.map (String.chop_prefix s ~prefix) ~f:(fun rest ->
                platform, vcs_kind, protocol, rest)))))
    with
    | None -> Error (`Msg (Printf.sprintf "%S: invalid url" s))
    | Some (platform, vcs_kind, protocol, rest) ->
      let vcs_kind =
        (* When we would have matched the prefix regardless, we forget about the
           information. *)
        match protocol with
        | Ssh -> vcs_kind
        | Https ->
          (match platform with
           | GitHub | GitLab | Codeberg -> Git
           | Sourcehut -> vcs_kind
           | Bitbucket ->
             (* For bitbucket, since this could be ambiguous, we have to decide
                between requiring the ".git" suffix, or not being able to parse
                hg url. The Sunsetting of Mercurial support in Bitbucket
                happened in 2020. We favor greater compatibility with Git users
                here. Note the library is still able to produce a url for hg
                repo, just not parse one. *)
             Vcs_kind.Git)
      in
      (match
         let* user_handle, rest =
           String.lsplit2 rest ~on:'/' |> Result.of_option ~error:"missing user handle"
         in
         let* user_handle =
           let* user_handle =
             match platform with
             | Sourcehut ->
               String.chop_prefix user_handle ~prefix:"~"
               |> Result.of_option
                    ~error:
                      "User namespace on sourcehut are expected to start with a '~' char."
             | GitHub | GitLab | Bitbucket | Codeberg -> Result.return user_handle
           in
           match User_handle.of_string user_handle with
           | Ok _ as ok -> ok
           | Error (`Msg m) -> Error m
         in
         let* repo_name =
           match String.chop_suffix rest ~suffix:".git" with
           | None -> Ok rest
           | Some repo_name ->
             (match vcs_kind with
              | Git -> Ok repo_name
              | Hg -> Error "Expected a hg repo but has a .git suffix.")
         in
         let* repo_name =
           match Repo_name.of_string repo_name with
           | Ok _ as ok -> ok
           | Error (`Msg m) -> Error m
         in
         Result.return { platform; vcs_kind; user_handle; repo_name; protocol }
       with
       | Ok _ as ok -> ok
       | Error e -> Error (`Msg (Printf.sprintf "%S: invalid url. %s" s e)))
  ;;

  let v str =
    match of_string str with
    | Ok t -> t
    | Error (`Msg m) -> raise (Invalid_argument m)
  ;;
end

let to_url { platform; vcs_kind; user_handle; repo_name } ~protocol =
  { Url.platform; vcs_kind; user_handle; repo_name; protocol }
;;

let of_url { Url.platform; vcs_kind; user_handle; repo_name; protocol = _ } =
  { platform; vcs_kind; user_handle; repo_name }
;;
