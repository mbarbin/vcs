(*_******************************************************************************)
(*_  Volgo - a Versatile OCaml Library for Git Operations                       *)
(*_  Copyright (C) 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>          *)
(*_                                                                             *)
(*_  This file is part of Volgo.                                                *)
(*_                                                                             *)
(*_  Volgo is free software; you can redistribute it and/or modify it under     *)
(*_  the terms of the GNU Lesser General Public License as published by the     *)
(*_  Free Software Foundation either version 3 of the License, or any later     *)
(*_  version, with the LGPL-3.0 Linking Exception.                              *)
(*_                                                                             *)
(*_  Volgo is distributed in the hope that it will be useful, but WITHOUT ANY   *)
(*_  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*_  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*_  the file `NOTICE.md` at the root of this repository for more details.      *)
(*_                                                                             *)
(*_  You should have received a copy of the GNU Lesser General Public License   *)
(*_  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*_  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*_******************************************************************************)

(** Helper library to write tests using vcs. *)

(** This takes care of setting the user config with dummy values, so that you
    can use [Vcs.commit] without having to worry about your user config on
    your machine. This isolates the test from your local settings, and also
    makes things work when running in the GitHub Actions environment, where no
    default user config exists. *)
val init
  :  < Vcs.Trait.config ; Vcs.Trait.init ; .. > Vcs.t
  -> path:Absolute_path.t
  -> Vcs.Repo_root.t

type 'a env = 'a
  constraint
    'a =
    < fs : [> Eio.Fs.dir_ty ] Eio.Path.t
    ; process_mgr : [> [> `Generic ] Eio.Process.mgr_ty ] Eio.Resource.t
    ; .. >

(** Create a fresh temporary directory and initiate a repo in it. The switch
    provided is used to attach a task that will discard the repo when the
    switch is released. *)
val init_temp_repo
  :  env:_ env
  -> sw:Eio.Switch.t
  -> vcs:< Vcs.Trait.config ; Vcs.Trait.init ; .. > Vcs.t
  -> Vcs.Repo_root.t

(** This helper allows to filter out unstable and brittle parts of errors before
    printing them in an expect test trace. The [fields] parameter specifies
    which field-paths to redact.

    In its most simple form, a [field] may simply be a field name that will end
    up being redacted. For example, if the error is:

    {[
      ((field_a ...)
       (field_b <UNSTABLE>))
    ]}

    then the [fields] parameter should be [["field_b"]], and in this case,
    [redact_sexp error ~fields:["field_b"]] will result in:

    {[
      ((field_a ...)
       (field_b <REDACTED>))
    ]}

    Some form of nesting is supported for convenience: in case you only want to
    redact a field if it is nested deep into another field. In this case, the
    syntax is to use a ["/"] separator in the field. For example, if the error
    is:

    {[
      ((steps ((Vcs.init ((path /invalid/path)))))
       (error (
         (prog git)
         (args (init .))
         (exit_status Unknown)
         (cwd         /invalid/path)
         (stdout      "")
         (stderr      "")
         (error       <UNSTABLE>))))
    ]}

    then the [fields] parameter should be [["error/error"]]. You may mix nested
    and non-nested fields in the same [fields] list. *)
val redact_sexp : Sexp.t -> fields:string list -> Sexp.t
