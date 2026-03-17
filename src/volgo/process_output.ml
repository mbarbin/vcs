(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

module T = struct
  [@@@coverage off]

  type t =
    { exit_code : int
    ; stdout : string
    ; stderr : string
    }

  let to_dyn { exit_code; stdout; stderr } =
    Dyn.record
      [ "exit_code", Dyn.int exit_code
      ; "stdout", Dyn.string stdout
      ; "stderr", Dyn.string stderr
      ]
  ;;

  let sexp_of_t t = Dyn.to_sexp (to_dyn t)
end

include T

module Private = struct
  let of_process_output t = t
end
