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
