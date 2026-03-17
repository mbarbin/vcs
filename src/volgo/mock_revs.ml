(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

type t =
  { of_mock : Rev.t Rev_table.t
  ; to_mock : Rev.t Rev_table.t
  ; mock_rev_gen : Mock_rev_gen.t
  }

let create () =
  let mock_rev_gen = Mock_rev_gen.create ~name:"mock-revs" in
  let size = 17 in
  { of_mock = Rev_table.create size; to_mock = Rev_table.create size; mock_rev_gen }
;;

let next t = Mock_rev_gen.next t.mock_rev_gen

let add_exn t ~rev ~mock_rev =
  Rev_table.add_exn t.to_mock ~key:rev ~data:mock_rev;
  Rev_table.add_exn t.of_mock ~key:mock_rev ~data:rev
;;

let to_mock t ~rev =
  match Rev_table.find t.to_mock rev with
  | Some rev -> rev
  | None ->
    let mock_rev = next t in
    add_exn t ~rev ~mock_rev;
    mock_rev
;;

let of_mock t ~mock_rev = Rev_table.find t.of_mock mock_rev
