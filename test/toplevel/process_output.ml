(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

(* @mdexp

   # Process output

   This test monitors that the types to manipulate the output of the `git` and
   `hg` processes are not unifiable, for the purpose of added type safety. *)

let%expect_test "git and hg output types are incompatible" =
  Ocaml_toplevel.eval
    ~code:
      {|
open Volgo;;

let process_git_output (_ : Vcs.Git.Output.t) = ()

let () =
  let hg_output = { Vcs.Hg.Output.exit_code = 0; stdout = ""; stderr = "" } in
  process_git_output hg_output
;;
|};
  (* @mdexp.snapshot *)
  [%expect
    {|
    ```ocaml
    open Volgo;;

    let process_git_output (_ : Vcs.Git.Output.t) = ()

    let () =
      let hg_output = { Vcs.Hg.Output.exit_code = 0; stdout = ""; stderr = "" } in
      process_git_output hg_output
    ;;
    ```

    ```terminal
    [1mLine 6, characters 21-30[0m:
    6 |   process_git_output hg_output
                             [1;31m^^^^^^^^^[0m
    [1;31mError[0m: The value [1mhg_output[0m has type
             [1mVolgo.Vcs.Hg.Output.t[0m = [1mVolgo__Hg.Output.t[0m
           but an expression was expected of type
             [1mVolgo.Vcs.Git.Output.t[0m = [1mVolgo__Git.Output.t[0m
    ```
    |}]
;;
