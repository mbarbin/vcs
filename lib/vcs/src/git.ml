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

module Output = struct
  [@@@coverage off]

  type t = Git_output0.t =
    { exit_code : int
    ; stdout : string
    ; stderr : string
    }
  [@@deriving sexp_of]
end

module type S = Vcs_interface.Process_S

module Result_impl = struct
  let exit0 { Output.exit_code; stdout = _; stderr = _ } =
    if Int.equal exit_code 0
    then Ok ()
    else Error (Err.error_string "expected exit code 0")
  ;;

  let exit0_and_stdout { Output.exit_code; stdout; stderr = _ } =
    if Int.equal exit_code 0
    then Ok stdout
    else Error (Err.error_string "expected exit code 0")
  ;;

  let exit_code { Output.exit_code; stdout = _; stderr = _ } ~accept =
    match List.find accept ~f:(fun (code, _) -> Int.equal exit_code code) with
    | Some (_, result) -> Ok result
    | None ->
      Error
        (Err.create_s
           [%sexp
             "unexpected exit code"
             , { accepted_codes : int list = List.map accept ~f:fst }])
  ;;
end

module Non_raising = struct
  module type M = Vcs_interface.Error_S

  module Make (M : M) : S with type 'a result := ('a, M.t) Result.t = struct
    let map_result = function
      | Ok x -> Ok x
      | Error err -> Error (M.of_err err)
    ;;

    let exit0 output = Result_impl.exit0 output |> map_result
    let exit0_and_stdout output = Result_impl.exit0_and_stdout output |> map_result
    let exit_code output ~accept = Result_impl.exit_code output ~accept |> map_result
  end
end

let err_exn = function
  | Ok x -> x
  | Error err -> raise (Exn0.E err)
;;

let exit0 output = Result_impl.exit0 output |> err_exn
let exit0_and_stdout output = Result_impl.exit0_and_stdout output |> err_exn
let exit_code output ~accept = Result_impl.exit_code output ~accept |> err_exn

module Or_error = Non_raising.Make (Vcs_or_error0)
module Rresult = Non_raising.Make (Vcs_rresult0)
module Result = Result_impl
