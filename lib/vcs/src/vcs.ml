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

module Author = Author
module Branch_name = Branch_name
module Commit_message = Commit_message
module Err = Err
module File_contents = File_contents
module Git = Git
module Log = Log
module Mock_rev_gen = Mock_rev_gen
module Mock_revs = Mock_revs
module Name_status = Name_status
module Num_status = Num_status
module Num_lines_in_diff = Num_lines_in_diff
module Path_in_repo = Path_in_repo
module Platform = Platform
module Ref_kind = Ref_kind
module Refs = Refs
module Remote_branch_name = Remote_branch_name
module Remote_name = Remote_name
module Repo_name = Repo_name
module Repo_root = Repo_root
module Rev = Rev
module Rev_parse = Rev_parse
module Tag_name = Tag_name
module Trait = Trait
module Tree = Tree
module Url = Url
module User_email = User_email
module User_handle = User_handle
module User_name = User_name
include Exn0

type 'a t = 'a Provider.t

let create provider = provider

let of_result ~step = function
  | Ok r -> r
  | Error error -> raise (E (Err.init error ~step:(force step)))
;;

let load_file (Provider.T { t; interface }) ~path =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.File_system) in
  M.load_file t ~path
  |> of_result ~step:(lazy [%sexp "Vcs.load_file", { path : Absolute_path.t }])
;;

let save_file ?perms (Provider.T { t; interface }) ~path ~file_contents =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.File_system) in
  M.save_file ?perms t ~path ~file_contents
  |> of_result
       ~step:
         (lazy [%sexp "Vcs.save_file", { perms : int option; path : Absolute_path.t }])
;;

let add (Provider.T { t; interface }) ~repo_root ~path =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Add) in
  M.add t ~repo_root ~path
  |> of_result
       ~step:(lazy [%sexp "Vcs.add", { repo_root : Repo_root.t; path : Path_in_repo.t }])
;;

let init (Provider.T { t; interface }) ~path =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Init) in
  M.init t ~path |> of_result ~step:(lazy [%sexp "Vcs.init", { path : Absolute_path.t }])
;;

let rev_parse (Provider.T { t; interface }) ~repo_root ~arg =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Rev_parse) in
  M.rev_parse t ~repo_root ~arg
  |> of_result
       ~step:
         (lazy
           [%sexp "Vcs.rev_parse", { repo_root : Repo_root.t; arg : Rev_parse.Arg.t }])
;;

let commit (Provider.T { t; interface }) ~repo_root ~commit_message =
  let module R = (val Provider.Interface.lookup interface ~trait:Trait.Rev_parse) in
  let module C = (val Provider.Interface.lookup interface ~trait:Trait.Commit) in
  (let%bind () = C.commit t ~repo_root ~commit_message in
   R.rev_parse t ~repo_root ~arg:Head)
  |> of_result ~step:(lazy [%sexp "Vcs.commit", { repo_root : Repo_root.t }])
;;

let ls_files (Provider.T { t; interface }) ~repo_root ~below =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Ls_files) in
  M.ls_files t ~repo_root ~below
  |> of_result
       ~step:
         (lazy
           [%sexp "Vcs.ls_files", { repo_root : Repo_root.t; below : Path_in_repo.t }])
;;

let rename_current_branch (Provider.T { t; interface }) ~repo_root ~to_ =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Branch) in
  M.rename_current_branch t ~repo_root ~to_
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.rename_current_branch", { repo_root : Repo_root.t; to_ : Branch_name.t }])
;;

let name_status (Provider.T { t; interface }) ~repo_root ~changed =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Name_status) in
  M.diff t ~repo_root ~changed
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.name_status"
             , { repo_root : Repo_root.t; changed : Name_status.Changed.t }])
;;

let num_status (Provider.T { t; interface }) ~repo_root ~changed =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Num_status) in
  M.diff t ~repo_root ~changed
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.num_status", { repo_root : Repo_root.t; changed : Num_status.Changed.t }])
;;

let log (Provider.T { t; interface }) ~repo_root =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Log) in
  M.all t ~repo_root
  |> of_result ~step:(lazy [%sexp "Vcs.log", { repo_root : Repo_root.t }])
;;

let refs (Provider.T { t; interface }) ~repo_root =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Refs) in
  M.show_ref t ~repo_root
  |> of_result ~step:(lazy [%sexp "Vcs.refs", { repo_root : Repo_root.t }])
;;

let tree (Provider.T { t; interface }) ~repo_root =
  let module L = (val Provider.Interface.lookup interface ~trait:Trait.Log) in
  let module R = (val Provider.Interface.lookup interface ~trait:Trait.Refs) in
  let tree = Tree.create () in
  (let%bind log = L.all t ~repo_root in
   let%bind refs = R.show_ref t ~repo_root in
   Tree.add_nodes tree ~log;
   List.iter refs ~f:(fun { rev; ref_kind } -> Tree.set_ref tree ~rev ~ref_kind);
   return tree)
  |> of_result ~step:(lazy [%sexp "Vcs.tree", { repo_root : Repo_root.t }])
;;

let set_user_name (Provider.T { t; interface }) ~repo_root ~user_name =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Config) in
  M.set_user_name t ~repo_root ~user_name
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.set_user_name", { repo_root : Repo_root.t; user_name : User_name.t }])
;;

let set_user_email (Provider.T { t; interface }) ~repo_root ~user_email =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Config) in
  M.set_user_email t ~repo_root ~user_email
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.set_user_email", { repo_root : Repo_root.t; user_email : User_email.t }])
;;

let show_file_at_rev (Provider.T { t; interface }) ~repo_root ~rev ~path =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Show) in
  M.show_file_at_rev t ~repo_root ~rev ~path
  |> of_result
       ~step:
         (lazy
           [%sexp
             "Vcs.show_file_at_rev"
             , { repo_root : Repo_root.t; rev : Rev.t; path : Path_in_repo.t }])
;;

let git
  ?env
  ?(run_in_subdir = Path_in_repo.root)
  (Provider.T { t; interface })
  ~repo_root
  ~args
  ~f
  =
  let module M = (val Provider.Interface.lookup interface ~trait:Trait.Git) in
  let cwd = Repo_root.append repo_root run_in_subdir in
  M.git ?env t ~cwd ~args ~f:(fun output -> Or_error.try_with (fun () -> f output))
  |> of_result
       ~step:(lazy [%sexp "Vcs.git", { cwd : Absolute_path.t; args : string list }])
;;

module Non_raising = struct
  module type M = sig
    type err

    val map_error : Err.t -> err
    val to_error : err -> Error.t
  end

  module type S = sig
    type err
    type 'a result := ('a, err) Result.t

    val init : [> Trait.init ] t -> path:Absolute_path.t -> Repo_root.t result

    val add
      :  [> Trait.add ] t
      -> repo_root:Repo_root.t
      -> path:Path_in_repo.t
      -> unit result

    val commit
      :  [> Trait.rev_parse | Trait.commit ] t
      -> repo_root:Repo_root.t
      -> commit_message:Commit_message.t
      -> Rev.t result

    val ls_files
      :  [> Trait.ls_files ] t
      -> repo_root:Repo_root.t
      -> below:Path_in_repo.t
      -> Path_in_repo.t list result

    val show_file_at_rev
      :  [> Trait.show ] t
      -> repo_root:Repo_root.t
      -> rev:Rev.t
      -> path:Path_in_repo.t
      -> [ `Present of File_contents.t | `Absent ] result

    val load_file
      :  [> Trait.file_system ] t
      -> path:Absolute_path.t
      -> File_contents.t result

    val save_file
      :  ?perms:int
      -> [> Trait.file_system ] t
      -> path:Absolute_path.t
      -> file_contents:File_contents.t
      -> unit result

    val rename_current_branch
      :  [> Trait.branch ] t
      -> repo_root:Repo_root.t
      -> to_:Branch_name.t
      -> unit result

    val name_status
      :  [> Trait.name_status ] t
      -> repo_root:Repo_root.t
      -> changed:Name_status.Changed.t
      -> Name_status.t result

    val num_status
      :  [> Trait.num_status ] t
      -> repo_root:Repo_root.t
      -> changed:Num_status.Changed.t
      -> Num_status.t result

    val log : [> Trait.log ] t -> repo_root:Repo_root.t -> Log.t result
    val refs : [> Trait.refs ] t -> repo_root:Repo_root.t -> Refs.t result
    val tree : [> Trait.log | Trait.refs ] t -> repo_root:Repo_root.t -> Tree.t result

    val rev_parse
      :  [> Trait.rev_parse ] t
      -> repo_root:Repo_root.t
      -> arg:Rev_parse.Arg.t
      -> Rev.t result

    val set_user_name
      :  [> Trait.config ] t
      -> repo_root:Repo_root.t
      -> user_name:User_name.t
      -> unit result

    val set_user_email
      :  [> Trait.config ] t
      -> repo_root:Repo_root.t
      -> user_email:User_email.t
      -> unit result

    val git
      :  ?env:string array
      -> ?run_in_subdir:Path_in_repo.t
      -> [> Trait.git ] t
      -> repo_root:Repo_root.t
      -> args:string list
      -> f:(Git.Output.t -> 'a result)
      -> 'a result
  end

  module Make (M : M) : S with type err := M.err = struct
    let init vcs ~path =
      match init vcs ~path with
      | r -> Ok r
      | exception E err -> Error (M.map_error err)
    ;;

    let add vcs ~repo_root ~path =
      match add vcs ~repo_root ~path with
      | r -> Ok r
      | exception E err -> Error (M.map_error err)
    ;;

    let commit vcs ~repo_root ~commit_message =
      match commit vcs ~repo_root ~commit_message with
      | r -> Ok r
      | exception E err -> Error (M.map_error err)
    ;;

    let ls_files vcs ~repo_root ~below =
      match ls_files vcs ~repo_root ~below with
      | r -> Ok r
      | exception E err -> Error (M.map_error err)
    ;;

    let show_file_at_rev vcs ~repo_root ~rev ~path =
      match show_file_at_rev vcs ~repo_root ~rev ~path with
      | r -> Ok r
      | exception E err -> Error (M.map_error err)
    ;;

    let load_file vcs ~path =
      match load_file vcs ~path with
      | r -> Ok r
      | exception E err -> Error (M.map_error err)
    ;;

    let save_file ?perms vcs ~path ~file_contents =
      match save_file ?perms vcs ~path ~file_contents with
      | r -> Ok r
      | exception E err -> Error (M.map_error err)
    ;;

    let rename_current_branch vcs ~repo_root ~to_ =
      match rename_current_branch vcs ~repo_root ~to_ with
      | r -> Ok r
      | exception E err -> Error (M.map_error err)
    ;;

    let name_status vcs ~repo_root ~changed =
      match name_status vcs ~repo_root ~changed with
      | r -> Ok r
      | exception E err -> Error (M.map_error err)
    ;;

    let num_status vcs ~repo_root ~changed =
      match num_status vcs ~repo_root ~changed with
      | r -> Ok r
      | exception E err -> Error (M.map_error err)
    ;;

    let log vcs ~repo_root =
      match log vcs ~repo_root with
      | r -> Ok r
      | exception E err -> Error (M.map_error err)
    ;;

    let refs vcs ~repo_root =
      match refs vcs ~repo_root with
      | r -> Ok r
      | exception E err -> Error (M.map_error err)
    ;;

    let tree vcs ~repo_root =
      match tree vcs ~repo_root with
      | r -> Ok r
      | exception E err -> Error (M.map_error err)
    ;;

    let rev_parse vcs ~repo_root ~arg =
      match rev_parse vcs ~repo_root ~arg with
      | r -> Ok r
      | exception E err -> Error (M.map_error err)
    ;;

    let set_user_name vcs ~repo_root ~user_name =
      match set_user_name vcs ~repo_root ~user_name with
      | r -> Ok r
      | exception E err -> Error (M.map_error err)
    ;;

    let set_user_email vcs ~repo_root ~user_email =
      match set_user_email vcs ~repo_root ~user_email with
      | r -> Ok r
      | exception E err -> Error (M.map_error err)
    ;;

    let git
      ?env
      ?(run_in_subdir = Path_in_repo.root)
      (Provider.T { t; interface })
      ~repo_root
      ~args
      ~f
      =
      let module G = (val Provider.Interface.lookup interface ~trait:Trait.Git) in
      let cwd = Repo_root.append repo_root run_in_subdir in
      match
        G.git ?env t ~cwd ~args ~f:(fun output ->
          f output |> Result.map_error ~f:M.to_error)
      with
      | Ok t -> Ok t
      | Error error ->
        Error
          (M.map_error
             (Err.init
                error
                ~step:[%sexp "Vcs.git", { cwd : Absolute_path.t; args : string list }]))
    ;;
  end
end

module Vcs_or_error = struct
  type err = Error.t
  type 'a result = ('a, err) Result.t

  include Non_raising.Make (struct
      type nonrec err = err

      let map_error = Err.to_error
      let to_error = Fn.id
    end)
end

module Vcs_result = struct
  type err = [ `Vcs of Err.t ]
  type 'a result = ('a, err) Result.t

  include Non_raising.Make (struct
      type nonrec err = err

      let map_error err = `Vcs err
      let to_error (`Vcs err) = Err.to_error err
    end)

  let pp_error fmt (`Vcs err) = Stdlib.Format.pp_print_string fmt (Err.to_string_hum err)

  let open_error = function
    | Ok _ as r -> r
    | Error (`Vcs _) as r -> r
  ;;

  let error_to_msg (r : 'a result) =
    Result.map_error r ~f:(fun (`Vcs err) -> `Msg (Err.to_string_hum err))
  ;;
end

module For_test = struct
  let init vcs ~path =
    let%bind repo_root = Vcs_or_error.init vcs ~path in
    let%bind () =
      Vcs_or_error.set_user_name vcs ~repo_root ~user_name:(User_name.v "Test User")
    in
    let%bind () =
      Vcs_or_error.set_user_email
        vcs
        ~repo_root
        ~user_email:(User_email.v "test@example.com")
    in
    return repo_root
  ;;
end

module Or_error = Vcs_or_error
module Result = Vcs_result
