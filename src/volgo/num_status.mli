(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

module Key : sig
  type t =
    | One_file of Path_in_repo.t
    | Two_files of
        { src : Path_in_repo.t
        ; dst : Path_in_repo.t
        }

  include Container_key.S with type t := t
end

module Change : sig
  module Num_stat : sig
    (** The number of lines in diff is not always given by git - indeed
        sometimes the line of output for this file contains dash '-'
        characters in lieu of the number of insertions or deletions. According
        to [man git diff] this happens for binary files. *)
    type t =
      | Num_lines_in_diff of Num_lines_in_diff.t
      | Binary_file

    val sexp_of_t : t -> Sexp.t
    val to_dyn : t -> Dyn.t
    val equal : t -> t -> bool
  end

  type t =
    { key : Key.t
    ; num_stat : Num_stat.t
    }

  val sexp_of_t : t -> Sexp.t
  val to_dyn : t -> Dyn.t
  val equal : t -> t -> bool
end

type t = Change.t list

val sexp_of_t : t -> Sexp.t
val to_dyn : t -> Dyn.t

module Changed : sig
  (** Specifies which {!type:Num_status.t} we want to compute. *)
  type t = Name_status.Changed.t =
    | Between of
        { src : Rev.t
        ; dst : Rev.t
        }

  val sexp_of_t : t -> Sexp.t
  val to_dyn : t -> Dyn.t
  val equal : t -> t -> bool
end
