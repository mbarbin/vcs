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

module String_option = struct
  type t = string option

  let equal = Option.equal String.equal
  let sexp_of_t = Option.sexp_of_t String.sexp_of_t
end

module String_pair_option = struct
  type t = (string * string) option

  (* Polymorphic equality is adequate for this test type. *)
  let equal = Stdlib.( = )
  let sexp_of_t t = Option.sexp_of_t (fun (a, b) -> List [ Atom a; Atom b ]) t
end

(* Exercise the [sexp_of_t] functions to ensure they are not dead code. *)
let%expect_test "sexp_of_t coverage" =
  print_s (String_option.sexp_of_t (Some "hello"));
  [%expect {| (hello) |}];
  print_s (String_option.sexp_of_t None);
  [%expect {| () |}];
  print_s (String_pair_option.sexp_of_t (Some ("a", "b")));
  [%expect {| ((a b)) |}];
  print_s (String_pair_option.sexp_of_t None);
  [%expect {| () |}];
  ()
;;

(* We rely on [String.sub] accepting [pos = length t] when [len = 0]. *)
let%expect_test "sub with pos = length t and len = 0" =
  let t = "hello" in
  require_equal [%here] (module String) (String.sub t ~pos:(String.length t) ~len:0) "";
  [%expect {||}];
  ()
;;

let%expect_test "is_empty" =
  let require str ~expect =
    require_equal [%here] (module Bool) (String.is_empty str) expect
  in
  require "" ~expect:true;
  require "a" ~expect:false;
  require "hello" ~expect:false;
  require " " ~expect:false;
  [%expect {||}];
  ()
;;

let%expect_test "chop_prefix" =
  let require_some str ~prefix ~expect =
    require_equal
      [%here]
      (module String_option)
      (String.chop_prefix str ~prefix)
      (Some expect)
  in
  let require_none str ~prefix =
    require_equal [%here] (module String_option) (String.chop_prefix str ~prefix) None
  in
  require_some "hello world" ~prefix:"hello " ~expect:"world";
  require_some "hello" ~prefix:"hello" ~expect:"";
  require_some "hello" ~prefix:"" ~expect:"hello";
  require_some "" ~prefix:"" ~expect:"";
  require_some "abc" ~prefix:"a" ~expect:"bc";
  require_none "hello world" ~prefix:"world";
  require_none "hello" ~prefix:"hello world";
  require_none "" ~prefix:"a";
  require_none "abc" ~prefix:"ABC";
  [%expect {||}];
  ()
;;

let%expect_test "chop_suffix" =
  let require_some str ~suffix ~expect =
    require_equal
      [%here]
      (module String_option)
      (String.chop_suffix str ~suffix)
      (Some expect)
  in
  let require_none str ~suffix =
    require_equal [%here] (module String_option) (String.chop_suffix str ~suffix) None
  in
  require_some "hello world" ~suffix:"world" ~expect:"hello ";
  require_some "hello" ~suffix:"hello" ~expect:"";
  require_some "hello" ~suffix:"" ~expect:"hello";
  require_some "" ~suffix:"" ~expect:"";
  require_some "abc" ~suffix:"c" ~expect:"ab";
  require_none "hello world" ~suffix:"hello";
  require_none "hello" ~suffix:"hello world";
  require_none "" ~suffix:"a";
  require_none "abc" ~suffix:"ABC";
  [%expect {||}];
  ()
;;

let%expect_test "lsplit2" =
  let require_some str ~on ~expect =
    require_equal
      [%here]
      (module String_pair_option)
      (String.lsplit2 str ~on)
      (Some expect)
  in
  let require_none str ~on =
    require_equal [%here] (module String_pair_option) (String.lsplit2 str ~on) None
  in
  require_some "hello:world" ~on:':' ~expect:("hello", "world");
  require_some ":hello" ~on:':' ~expect:("", "hello");
  (* Boundary: split char at end, second part is empty (pos = length t, len = 0). *)
  require_some "hello:" ~on:':' ~expect:("hello", "");
  require_some ":" ~on:':' ~expect:("", "");
  require_some "a:b:c" ~on:':' ~expect:("a", "b:c");
  require_some "hello world" ~on:' ' ~expect:("hello", "world");
  require_none "hello" ~on:':';
  require_none "" ~on:':';
  [%expect {||}];
  ()
;;

let%expect_test "rsplit2" =
  let require_some str ~on ~expect =
    require_equal
      [%here]
      (module String_pair_option)
      (String.rsplit2 str ~on)
      (Some expect)
  in
  let require_none str ~on =
    require_equal [%here] (module String_pair_option) (String.rsplit2 str ~on) None
  in
  require_some "hello:world" ~on:':' ~expect:("hello", "world");
  require_some ":hello" ~on:':' ~expect:("", "hello");
  (* Boundary: split char at end, second part is empty (pos = length t, len = 0). *)
  require_some "hello:" ~on:':' ~expect:("hello", "");
  require_some ":" ~on:':' ~expect:("", "");
  require_some "a:b:c" ~on:':' ~expect:("a:b", "c");
  require_some "hello world" ~on:' ' ~expect:("hello", "world");
  require_none "hello" ~on:':';
  require_none "" ~on:':';
  [%expect {||}];
  ()
;;
