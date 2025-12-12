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

open! Import

module Line = struct
  [@@@coverage off]

  type t =
    | Root of { rev : Rev.t }
    | Commit of
        { rev : Rev.t
        ; parent : Rev.t
        }
    | Merge of
        { rev : Rev.t
        ; parent1 : Rev.t
        ; parent2 : Rev.t
        }
  [@@deriving_inline sexp_of]

  let sexp_of_t =
    (function
     | Root { rev = rev__002_ } ->
       let bnds__001_ = ([] : _ Stdlib.List.t) in
       let bnds__001_ =
         let arg__003_ = Rev.sexp_of_t rev__002_ in
         (Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "rev"; arg__003_ ] :: bnds__001_
          : _ Stdlib.List.t)
       in
       Sexplib0.Sexp.List (Sexplib0.Sexp.Atom "Root" :: bnds__001_)
     | Commit { rev = rev__005_; parent = parent__007_ } ->
       let bnds__004_ = ([] : _ Stdlib.List.t) in
       let bnds__004_ =
         let arg__008_ = Rev.sexp_of_t parent__007_ in
         (Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "parent"; arg__008_ ] :: bnds__004_
          : _ Stdlib.List.t)
       in
       let bnds__004_ =
         let arg__006_ = Rev.sexp_of_t rev__005_ in
         (Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "rev"; arg__006_ ] :: bnds__004_
          : _ Stdlib.List.t)
       in
       Sexplib0.Sexp.List (Sexplib0.Sexp.Atom "Commit" :: bnds__004_)
     | Merge { rev = rev__010_; parent1 = parent1__012_; parent2 = parent2__014_ } ->
       let bnds__009_ = ([] : _ Stdlib.List.t) in
       let bnds__009_ =
         let arg__015_ = Rev.sexp_of_t parent2__014_ in
         (Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "parent2"; arg__015_ ] :: bnds__009_
          : _ Stdlib.List.t)
       in
       let bnds__009_ =
         let arg__013_ = Rev.sexp_of_t parent1__012_ in
         (Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "parent1"; arg__013_ ] :: bnds__009_
          : _ Stdlib.List.t)
       in
       let bnds__009_ =
         let arg__011_ = Rev.sexp_of_t rev__010_ in
         (Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "rev"; arg__011_ ] :: bnds__009_
          : _ Stdlib.List.t)
       in
       Sexplib0.Sexp.List (Sexplib0.Sexp.Atom "Merge" :: bnds__009_)
     : t -> Sexplib0.Sexp.t)
  ;;

  [@@@deriving.end]

  let equal =
    (fun a__001_ b__002_ ->
       if a__001_ == b__002_
       then true
       else (
         match a__001_, b__002_ with
         | Root _a__003_, Root _b__004_ -> Rev.equal _a__003_.rev _b__004_.rev
         | Root _, _ -> false
         | _, Root _ -> false
         | Commit _a__005_, Commit _b__006_ ->
           Rev.equal _a__005_.rev _b__006_.rev
           && Rev.equal _a__005_.parent _b__006_.parent
         | Commit _, _ -> false
         | _, Commit _ -> false
         | Merge _a__007_, Merge _b__008_ ->
           Rev.equal _a__007_.rev _b__008_.rev
           && Rev.equal _a__007_.parent1 _b__008_.parent1
           && Rev.equal _a__007_.parent2 _b__008_.parent2)
     : t -> t -> bool)
  ;;

  let rev = function
    | Commit { rev; _ } | Merge { rev; _ } | Root { rev } -> rev
  ;;
end

module T = struct
  [@@@coverage off]

  type t = Line.t list [@@deriving_inline sexp_of]

  let sexp_of_t =
    (fun x__016_ -> sexp_of_list Line.sexp_of_t x__016_ : t -> Sexplib0.Sexp.t)
  ;;

  [@@@deriving.end]

  let equal a b = equal_list Line.equal a b
end

include T

let roots (t : t) =
  List.filter_map t ~f:(fun line ->
    match (line : Line.t) with
    | Root { rev } -> Some rev
    | Commit _ | Merge _ -> None)
;;
