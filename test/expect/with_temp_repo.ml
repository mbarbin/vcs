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

type 'a env = 'a
  constraint
    'a =
    < fs : [> Eio.Fs.dir_ty ] Eio.Path.t
    ; process_mgr : [> [> `Generic ] Eio.Process.mgr_ty ] Eio.Resource.t
    ; .. >

let run ~env f =
  Eio.Switch.run
  @@ fun sw ->
  (* To use the [Vcs] API, you need a [vcs] value, which you must obtain from a
     provider. We're using [Vcs_git] for this here. It is a provider based on
     [Eio] and running the [git] command line as an external process. *)
  let vcs = Vcs_git.create ~env in
  (* The next step takes care of creating a repository and initializing the git
     users's config with some dummy values so we can use [commit] without having
     to worry about your user config on your machine. This isolates the test
     from your local settings, and also makes things work when running in the
     GitHub Actions environment, where no default user config exists. *)
  let repo_root =
    let path = Stdlib.Filename.temp_dir ~temp_dir:(Unix.getcwd ()) "vcs" "test" in
    Eio.Switch.on_release sw (fun () ->
      Eio.Path.rmtree Eio.Path.(Eio.Stdenv.fs env / path));
    Vcs.For_test.init vcs ~path:(Absolute_path.v path) |> Or_error.ok_exn
  in
  f ~vcs ~repo_root
;;
