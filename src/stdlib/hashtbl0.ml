(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

include (
  MoreLabels.Hashtbl :
    module type of MoreLabels.Hashtbl with module Make := MoreLabels.Hashtbl.Make)

module type S_extended = sig
  include MoreLabels.Hashtbl.S

  val add_exn : 'a t -> key:key -> data:'a -> unit
  val add_multi : 'a list t -> key:key -> data:'a -> unit
  val find : 'a t -> key -> 'a option
  val set : 'a t -> key:key -> data:'a -> unit
end

exception E of Sexp.t

let () =
  Sexplib0.Sexp_conv.Exn_converter.add [%extension_constructor E] (function
    | E sexp -> sexp
    | _ -> assert false)
;;

module Make (H : sig
    include Hashtbl.HashedType

    val sexp_of_t : t -> Sexp.t
  end) =
struct
  include MoreLabels.Hashtbl.Make (H)

  let add_exn t ~key ~data =
    if mem t key
    then
      raise
        (E
           (List
              [ Atom "Hashtbl.add_exn: key already present"
              ; Sexp.List [ Atom "key"; H.sexp_of_t key ]
              ]))
    else add t ~key ~data
  ;;

  let add_multi t ~key ~data =
    let data =
      match find_opt t key with
      | None -> [ data ]
      | Some l -> data :: l
    in
    replace t ~key ~data
  ;;

  let find = find_opt
  let set = replace
end
