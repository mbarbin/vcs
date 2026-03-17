(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

let%expect_test "to_string_hum" =
  List.iter Vcs.Platform.all ~f:(fun t -> print_endline (Vcs.Platform.to_string t));
  [%expect
    {|
    Bitbucket
    Codeberg
    GitHub
    GitLab
    Sourcehut
    |}];
  ()
;;

let%expect_test "sexp_of_t" =
  let test t = print_s (t |> Vcs.Platform.sexp_of_t) in
  test GitLab;
  [%expect {| GitLab |}];
  ()
;;
