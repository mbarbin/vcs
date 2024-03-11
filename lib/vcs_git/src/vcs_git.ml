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

module Runtime = struct
  type t =
    { fs : Eio_extended.Path.t'
    ; process_mgr : Eio_extended.Process.mgr'
    }

  let name _ = "git"

  let create ~env =
    { fs = (Eio.Stdenv.fs env :> Eio_extended.Path.t')
    ; process_mgr = (Eio.Stdenv.process_mgr env :> Eio_extended.Process.mgr')
    }
  ;;

  let load_file t ~path =
    let path = Eio.Path.(t.fs / Absolute_path.to_string path) in
    Or_error.try_with (fun () -> Vcs.File_contents.create (Eio.Path.load path))
  ;;

  let save_file ?(perms = 0o600) t ~path ~(file_contents : Vcs.File_contents.t) =
    let path = Eio.Path.(t.fs / Absolute_path.to_string path) in
    Or_error.try_with (fun () ->
      Eio.Path.save ~create:(`Or_truncate perms) path (file_contents :> string))
  ;;

  let git ?env t ~cwd ~args ~f =
    Eio_process.run
      ~process_mgr:t.process_mgr
      ~cwd:Eio.Path.(t.fs / Absolute_path.to_string cwd)
      ?env
      ~prog:"git"
      ~args
      ()
      ~f:(fun { Eio_process.Output.stdout; stderr; exit_status } ->
        match exit_status with
        | `Exited exit_code -> f { Vcs.Git.Output.exit_code; stdout; stderr }
        | `Signaled signal ->
          Or_error.error_s [%sexp "process exited abnormally", { signal : int }])
  ;;
end

module Impl = struct
  include Runtime
  module Add = Git_cli.Add.Make (Runtime)
  module Branch = Git_cli.Branch.Make (Runtime)
  module Commit = Git_cli.Commit.Make (Runtime)
  module Config = Git_cli.Config.Make (Runtime)
  module File_system = Runtime
  module Git = Runtime
  module Init = Git_cli.Init.Make (Runtime)
  module Log = Git_cli.Log.Make (Runtime)
  module Ls_files = Git_cli.Ls_files.Make (Runtime)
  module Name_status = Git_cli.Name_status.Make (Runtime)
  module Num_status = Git_cli.Num_status.Make (Runtime)
  module Refs = Git_cli.Refs.Make (Runtime)
  module Rev_parse = Git_cli.Rev_parse.Make (Runtime)
  module Show = Git_cli.Show.Make (Runtime)
end

type tag =
  [ Vcs.Trait.add
  | Vcs.Trait.branch
  | Vcs.Trait.commit
  | Vcs.Trait.config
  | Vcs.Trait.file_system
  | Vcs.Trait.git
  | Vcs.Trait.init
  | Vcs.Trait.log
  | Vcs.Trait.ls_files
  | Vcs.Trait.name_status
  | Vcs.Trait.num_status
  | Vcs.Trait.refs
  | Vcs.Trait.rev_parse
  | Vcs.Trait.show
  ]

type 'a t = ([> tag ] as 'a) Vcs.t
type t' = tag t

let interface () : (Impl.t, [> tag ]) Provider.Interface.t =
  Provider.Interface.make
    [ Provider.Trait.implement Vcs.Trait.Add ~impl:(module Impl.Add)
    ; Provider.Trait.implement Vcs.Trait.Branch ~impl:(module Impl.Branch)
    ; Provider.Trait.implement Vcs.Trait.Commit ~impl:(module Impl.Commit)
    ; Provider.Trait.implement Vcs.Trait.Config ~impl:(module Impl.Config)
    ; Provider.Trait.implement Vcs.Trait.File_system ~impl:(module Impl.File_system)
    ; Provider.Trait.implement Vcs.Trait.Git ~impl:(module Impl.Git)
    ; Provider.Trait.implement Vcs.Trait.Init ~impl:(module Impl.Init)
    ; Provider.Trait.implement Vcs.Trait.Log ~impl:(module Impl.Log)
    ; Provider.Trait.implement Vcs.Trait.Ls_files ~impl:(module Impl.Ls_files)
    ; Provider.Trait.implement Vcs.Trait.Name_status ~impl:(module Impl.Name_status)
    ; Provider.Trait.implement Vcs.Trait.Num_status ~impl:(module Impl.Num_status)
    ; Provider.Trait.implement Vcs.Trait.Refs ~impl:(module Impl.Refs)
    ; Provider.Trait.implement Vcs.Trait.Rev_parse ~impl:(module Impl.Rev_parse)
    ; Provider.Trait.implement Vcs.Trait.Show ~impl:(module Impl.Show)
    ]
;;

let create ~env =
  Vcs.create (Provider.T { t = Impl.create ~env; interface = interface () })
;;
