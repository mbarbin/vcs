(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type err = Vcs_rresult0.t

let sexp_of_err = Vcs_rresult0.sexp_of_t

type 'a t = ('a, err) Result.t

let sexp_of_t sexp_of_a t = Result.sexp_of_t sexp_of_a sexp_of_err t

type 'a result = 'a t

include Non_raising.Make (Vcs_rresult0)

let pp_error fmt (`Vcs err) = Format.pp_print_string fmt (Err.to_string_hum err)

let open_error = function
  | Ok _ as r -> r
  | Error (`Vcs _) as r -> r
;;

let error_to_msg (r : 'a result) =
  Result.map_error r ~f:(fun (`Vcs err) -> `Msg (Err.to_string_hum err))
;;
