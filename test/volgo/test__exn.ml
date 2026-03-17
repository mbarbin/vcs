(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "reraise_with_context" =
  let () =
    let err = Err.create [ Pp.verbatim "Err" ] in
    match
      match raise (Err.E err) with
      | _ -> assert false
      | exception Err.E err ->
        let bt = Printexc.get_raw_backtrace () in
        (Err.reraise_with_context err bt [ Pp.verbatim "Step" ] [@coverage off])
    with
    | _ -> assert false
    | exception Err.E err -> print_s (err |> Err.sexp_of_t)
  in
  [%expect {| ((context Step) (error Err)) |}];
  ()
;;
