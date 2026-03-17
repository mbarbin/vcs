(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "Int_table.add_exn" =
  let module Int_table = Vcs.Private.Int_table in
  let table = Int_table.create 3 in
  Int_table.add_exn table ~key:1_234 ~data:"one";
  require_does_raise (fun () -> Int_table.add_exn table ~key:1_234 ~data:"one prime");
  [%expect {| ("Hashtbl.add_exn: key already present" (key 1_234)) |}];
  ()
;;
