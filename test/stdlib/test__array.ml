(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "Array.to_list_mapi" =
  let test t ~f =
    let t1 = Array.to_list_mapi t ~f in
    print_dyn (Dyn.List t1)
  in
  test [||] ~f:(fun _ _ -> (assert false [@coverage off]));
  [%expect {| [] |}];
  test [| (); (); () |] ~f:(fun i _ -> Dyn.int i);
  [%expect {| [ 0; 1; 2 ] |}];
  test [| 0; 1; 2; 3; 4; 5 |] ~f:(fun i e -> Dyn.int (e - i));
  [%expect {| [ 0; 0; 0; 0; 0; 0 ] |}];
  ()
;;
