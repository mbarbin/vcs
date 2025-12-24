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

(* This module is partially derived from Iron (v0.9.114.44+47), file
 * [./common/path_in_repo.ml], which is released under Apache 2.0:
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
 * Changes: We removed the part related to the [Stable] serialization. The logic
 * is based on a different module for [Relative_path]. We removed the part that
 * related to [.fe] files.
 *)

include Relative_path

let root = Relative_path.empty
let to_fpath = Relative_path.to_fpath
let of_relative_path t = t
let to_relative_path t = t
let to_string = Relative_path.to_string

let of_string str =
  match str |> Relative_path.of_string with
  | Ok t -> Ok (t |> of_relative_path)
  | Error (`Msg _) as error -> error
;;

let v str =
  match str |> of_string with
  | Ok t -> t
  | Error (`Msg m) -> invalid_arg m
;;
