(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "List.equal" =
  let test a b = List.equal a b ~eq:Int.equal in
  let r = [ 1; 2; 3 ] in
  require (test r r);
  require (test [ 1; 2; 3 ] [ 1; 2; 3 ]);
  require (test [] []);
  require (not (test [ 1; 2; 3 ] [ 1; 2 ]));
  require (not (test [ 1; 2; 3 ] [ 1; 2; 4 ]));
  require (not (test [] [ 1 ]));
  ()
;;
