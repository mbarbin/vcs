(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(*_ This module is partially derived from Iron (v0.9.114.44+47), file
 * [./common/path_in_repo.mli], which is released under Apache 2.0:
 *
 * Copyright (c) 2016-2017 Jane Street Group, LLC <opensource-contacts@janestreet.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy
 * of the License at:
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 *
 * See the file `NOTICE.md` at the root of this repository for more details.
 *
 * The file [path_in_repo.ml] contains a detailed description of the changes made
 * to the original file.
 *)

(** A path for a file versioned in a repository.

    This is a wrapper for a [Fpath.t] relative to the repo root, used for
    accrued type safety. *)

type t (** @canonical Volgo.Vcs.Path_in_repo.t *)

include Container_key.S with type t := t
include Validated_string.S with type t := t

val root : t
val to_fpath : t -> Fpath.t
val to_relative_path : t -> Relative_path.t
val of_relative_path : Relative_path.t -> t
