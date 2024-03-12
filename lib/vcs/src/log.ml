(*******************************************************************************)
(*  Vcs - a versatile OCaml library for Git interaction                        *)
(*  Copyright (C) 2024 Mathieu Barbin <mathieu.barbin@gmail.com>               *)
(*                                                                             *)
(*  This file is part of Vcs.                                                  *)
(*                                                                             *)
(*  Vcs is free software; you can redistribute it and/or modify it under       *)
(*  the terms of the GNU Lesser General Public License as published by the     *)
(*  Free Software Foundation either version 3 of the License, or any later     *)
(*  version, with the LGPL-3.0 Linking Exception.                              *)
(*                                                                             *)
(*  Vcs is distributed in the hope that it will be useful, but WITHOUT ANY     *)
(*  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *)
(*  FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License and    *)
(*  the file `NOTICE.md` at the root of this repository for more details.      *)
(*                                                                             *)
(*  You should have received a copy of the GNU Lesser General Public License   *)
(*  and the LGPL-3.0 Linking Exception along with this library. If not, see    *)
(*  <http://www.gnu.org/licenses/> and <https://spdx.org>, respectively.       *)
(*******************************************************************************)

module Line = struct
  [@@@coverage off]

  type t =
    | Init of { rev : Rev.t }
    | Commit of
        { rev : Rev.t
        ; parent : Rev.t
        }
    | Merge of
        { rev : Rev.t
        ; parent1 : Rev.t
        ; parent2 : Rev.t
        }
  [@@deriving equal, sexp_of]

  let rev = function
    | Commit { rev; _ } | Merge { rev; _ } | Init { rev } -> rev
  ;;
end

module T = struct
  [@@@coverage off]

  type t = Line.t list [@@deriving equal, sexp_of]
end

include T

let roots (t : t) =
  let queue = Queue.create () in
  List.iter t ~f:(function
    | Init { rev } -> Queue.enqueue queue rev
    | Commit _ | Merge _ -> ());
  Queue.to_list queue
;;
