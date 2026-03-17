(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "require" =
  require true;
  [%expect {||}];
  require_does_raise (fun () -> require false);
  [%expect {| Failure("Required condition does not hold.") |}]
;;

let%expect_test "require_does_raise" =
  require_does_raise (fun () -> failwith "Hello Exn");
  [%expect {| Failure("Hello Exn") |}];
  ()
;;

let%expect_test "require_does_raise did not raise" =
  (match require_does_raise ignore with
   | () -> assert false
   | exception exn -> print_string (Printexc.to_string exn));
  [%expect {| ("Did not raise.", {}) |}];
  ()
;;

let%expect_test "require_equal not equal" =
  (match require_equal (module String) "zero" "42" with
   | () -> assert false
   | exception exn -> print_string (Printexc.to_string exn));
  [%expect {| ("Values are not equal.", { v1 = "zero"; v2 = "42" }) |}];
  ()
;;

let%expect_test "require_not_equal equal" =
  (match require_not_equal (module String) "zero" "zero" with
   | () -> assert false
   | exception exn -> print_string (Printexc.to_string exn));
  [%expect {| ("Values are equal.", { v1 = "zero"; v2 = "zero" }) |}];
  ()
;;
