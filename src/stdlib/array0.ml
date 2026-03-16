(*********************************************************************************)
(*  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*********************************************************************************)

include ArrayLabels

let sexp_of_t = Sexplib0.Sexp_conv.sexp_of_array
let create ~len a = make len a

let filter_mapi t ~f =
  let out_count = ref 0 in
  let out = ref [] in
  iteri t ~f:(fun i a ->
    match f i a with
    | None -> ()
    | Some e ->
      incr out_count;
      out := e :: !out);
  match !out with
  | [] -> [||]
  | hd :: _ ->
    let out_count = !out_count in
    let res = create ~len:out_count hd in
    List.iteri (fun i a -> res.(out_count - 1 - i) <- a) !out;
    res
;;

let rev a =
  let len = length a in
  let res = create ~len a.(0) in
  iteri a ~f:(fun i x -> res.(len - 1 - i) <- x);
  res
;;

let sort t ~compare = sort t ~cmp:compare

let[@tail_mod_cons] rec to_list_mapi_aux t ~f ~index ~len =
  if index >= len
  then []
  else (
    let elt = Array.unsafe_get t index in
    (* Coverage is off in the second part of the expression because the
       instrumentation breaks [@tail_mod_cons], triggering warning 71. *)
    f index elt :: (to_list_mapi_aux t ~f ~index:(index + 1) ~len [@coverage off]))
;;

let to_list_mapi t ~f = to_list_mapi_aux t ~f ~index:0 ~len:(Array.length t)
