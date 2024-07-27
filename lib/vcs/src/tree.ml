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

module Node_kind = struct
  module T = struct
    [@@@coverage off]

    type 'index t =
      | Root of { rev : Rev.t }
      | Commit of
          { rev : Rev.t
          ; parent : 'index
          }
      | Merge of
          { rev : Rev.t
          ; parent1 : 'index
          ; parent2 : 'index
          }
    [@@deriving equal, sexp_of]
  end

  include T

  let rev = function
    | Root { rev } -> rev
    | Commit { rev; _ } -> rev
    | Merge { rev; _ } -> rev
  ;;

  let map_index t ~f =
    match t with
    | Root { rev } -> Root { rev }
    | Commit { rev; parent } -> Commit { rev; parent = f parent }
    | Merge { rev; parent1; parent2 } ->
      Merge { rev; parent1 = f parent1; parent2 = f parent2 }
  ;;

  let to_log_line t ~f =
    match t with
    | Root { rev } -> Log.Line.Root { rev }
    | Commit { rev; parent } -> Log.Line.Commit { rev; parent = f parent }
    | Merge { rev; parent1; parent2 } ->
      Log.Line.Merge { rev; parent1 = f parent1; parent2 = f parent2 }
  ;;
end

module T = struct
  [@@@coverage off]

  type t =
    { mutable nodes : int Node_kind.t array
    ; revs : int Hashtbl.M(Rev).t
    ; refs : int Hashtbl.M(Ref_kind).t
    ; reverse_refs : Ref_kind.t list Hashtbl.M(Int).t
    }
  [@@deriving sexp_of]
end

include T

let create () =
  { nodes = [||]
  ; revs = Hashtbl.create (module Rev)
  ; refs = Hashtbl.create (module Ref_kind)
  ; reverse_refs = Hashtbl.create (module Int)
  }
;;

module Node0 = struct
  type t = int [@@deriving compare, equal, hash, sexp_of]

  let _ = hash_fold_t
  let rev t node = Node_kind.rev t.nodes.(node)

  let parents t node =
    match t.nodes.(node) with
    | Node_kind.Root _ -> []
    | Commit { parent; _ } -> [ parent ]
    | Merge { parent1; parent2; _ } -> [ parent1; parent2 ]
  ;;

  let node_kind t node = t.nodes.(node)

  let refs t node =
    Hashtbl.find t.reverse_refs node
    |> Option.value ~default:[]
    |> List.sort ~compare:Ref_kind.compare
  ;;
end

(* Helper function to iter over all ancestors of a given node, itself included.
   [visited] is taken as an input so we can re-use the same array multiple
   times, rather than re-allocating it. *)
let iter_ancestors t ~visited node ~f =
  Array.fill visited ~pos:0 ~len:(Array.length visited) false;
  let rec loop to_visit =
    match to_visit with
    | [] -> ()
    | node :: to_visit ->
      if not visited.(node)
      then (
        visited.(node) <- true;
        f node;
        match t.nodes.(node) with
        | Root _ -> loop to_visit
        | Commit { parent; _ } -> loop (parent :: to_visit)
        | Merge { parent1; parent2; _ } -> loop (parent1 :: parent2 :: to_visit))
  in
  loop [ node ]
;;

let greatest_common_ancestors t nodes =
  match nodes with
  | [] -> []
  | [ node ] -> [ node ]
  | node1 :: nodes ->
    let visited = Array.map t.nodes ~f:(Fn.const false) in
    let common_ancestors =
      iter_ancestors t ~visited node1 ~f:(fun _ -> ());
      Array.copy visited
    in
    List.iter nodes ~f:(fun node ->
      iter_ancestors t ~visited node ~f:(fun _ -> ());
      Array.iteri common_ancestors ~f:(fun i b ->
        common_ancestors.(i) <- b && visited.(i)));
    for i = Array.length common_ancestors - 1 downto 0 do
      if common_ancestors.(i)
      then
        iter_ancestors t ~visited i ~f:(fun j ->
          if j <> i then common_ancestors.(j) <- false)
    done;
    Array.filter_mapi common_ancestors ~f:(fun i b -> if b then Some i else None)
    |> Array.to_list
;;

let refs t =
  Hashtbl.to_alist t.refs
  |> List.sort ~compare:(fun (r1, _) (r2, _) -> Ref_kind.compare r1 r2)
  |> List.map ~f:(fun (ref_kind, index) ->
    { Refs.Line.rev = Node_kind.rev t.nodes.(index); ref_kind })
;;

let set_ref t ~rev ~ref_kind =
  match Hashtbl.find t.revs rev with
  | None -> raise_s [%sexp "Rev not found", (rev : Rev.t)]
  | Some index ->
    Hashtbl.set t.refs ~key:ref_kind ~data:index;
    Hashtbl.add_multi t.reverse_refs ~key:index ~data:ref_kind
;;

let set_refs t ~refs =
  List.iter refs ~f:(fun { Refs.Line.rev; ref_kind } -> set_ref t ~rev ~ref_kind)
;;

let find_ref t ~ref_kind = Hashtbl.find t.refs ref_kind
let mem_rev t ~rev = Hashtbl.mem t.revs rev
let find_rev t ~rev = Hashtbl.find t.revs rev

let add_nodes t ~log =
  let nodes_table =
    let table = Hashtbl.create (module Rev) in
    List.iter log ~f:(fun line ->
      Hashtbl.add_exn table ~key:(Log.Line.rev line) ~data:line);
    table
  in
  let new_nodes = Queue.create ~capacity:(List.length log) () in
  let visited = Hash_set.create (module Rev) in
  let is_visited rev =
    if Hash_set.mem visited rev
    then true
    else if mem_rev t ~rev
    then (
      Hash_set.add visited rev;
      true)
    else false
  in
  let rec visit (line : Log.Line.t) =
    match (line : Log.Line.t) with
    | Root { rev } ->
      if not (is_visited rev)
      then (
        Hash_set.add visited rev;
        Queue.enqueue new_nodes (Node_kind.Root { rev }))
    | Commit { rev; parent } ->
      if not (is_visited rev)
      then (
        Hash_set.add visited rev;
        if not (Hashtbl.mem t.revs parent)
        then visit (Hashtbl.find_exn nodes_table parent);
        Queue.enqueue new_nodes (Node_kind.Commit { rev; parent }))
    | Merge { rev; parent1; parent2 } ->
      if not (is_visited rev)
      then (
        Hash_set.add visited rev;
        if not (Hashtbl.mem t.revs parent1)
        then visit (Hashtbl.find_exn nodes_table parent1);
        if not (Hashtbl.mem t.revs parent2)
        then visit (Hashtbl.find_exn nodes_table parent2);
        Queue.enqueue new_nodes (Node_kind.Merge { rev; parent1; parent2 }))
  in
  (* We iter in reverse order to makes the depth of visited path shorter. *)
  List.iter (List.rev log) ~f:visit;
  let new_index = Array.length t.nodes in
  let new_nodes =
    Queue.to_array new_nodes
    |> Array.mapi ~f:(fun i node ->
      let index = new_index + i in
      let rev = Node_kind.rev node in
      Hashtbl.add_exn t.revs ~key:rev ~data:index;
      Node_kind.map_index node ~f:(fun rev -> Hashtbl.find_exn t.revs rev))
  in
  t.nodes <- Array.append t.nodes new_nodes;
  ()
;;

let roots t =
  Array.filter_mapi t.nodes ~f:(fun i node ->
    match node with
    | Root _ -> Some i
    | Commit _ | Merge _ -> None)
  |> Array.to_list
;;

let is_strict_ancestor t ~ancestor ~descendant =
  let visited = Hash_set.create (module Int) in
  let rec loop to_visit =
    match to_visit with
    | [] -> false
    | node :: to_visit ->
      (match Int.compare ancestor node |> Ordering.of_int with
       | Equal -> true
       | Greater -> loop to_visit
       | Less ->
         if Hash_set.mem visited node
         then loop to_visit
         else (
           Hash_set.add visited node;
           loop (Node0.parents t node @ to_visit)))
  in
  ancestor < descendant && loop [ descendant ]
;;

let is_ancestor_or_equal t ~ancestor ~descendant =
  ancestor = descendant || is_strict_ancestor t ~ancestor ~descendant
;;

module Node = struct
  include Node0

  module Descendance = struct
    [@@@coverage off]

    type t =
      | Same
      | Strict_ancestor
      | Strict_descendant
      | Unrelated
    [@@deriving equal, enumerate, hash, sexp_of]
  end

  let descendance t a b : Descendance.t =
    if a = b
    then Same
    else if is_strict_ancestor t ~ancestor:a ~descendant:b
    then Strict_ancestor
    else if is_strict_ancestor t ~ancestor:b ~descendant:a
    then Strict_descendant
    else Unrelated
  ;;
end

let tips t =
  let has_children = Hash_set.create (module Node) in
  Array.iter t.nodes ~f:(fun node ->
    match node with
    | Root _ -> ()
    | Commit { parent; _ } -> Hash_set.add has_children parent
    | Merge { parent1; parent2; _ } ->
      Hash_set.add has_children parent1;
      Hash_set.add has_children parent2);
  Array.filter_mapi t.nodes ~f:(fun i _ ->
    if Hash_set.mem has_children i then None else Some i)
  |> Array.to_list
;;

let log t =
  Array.map t.nodes ~f:(fun node ->
    Node_kind.to_log_line node ~f:(fun i -> Node_kind.rev t.nodes.(i)))
  |> Array.to_list
;;

module Subtree = struct
  module T = struct
    [@@@coverage off]

    type t =
      { log : Log.t
      ; refs : Refs.t
      }
    [@@deriving sexp_of]
  end

  include T

  let is_empty { log; refs } = List.is_empty log && List.is_empty refs
end

let of_subtree { Subtree.log; refs } =
  let t = create () in
  add_nodes t ~log;
  set_refs t ~refs;
  t
;;

let subtrees t =
  let dummy_cell = Union_find.create (-1) in
  let components = Array.map t.nodes ~f:(fun _ -> dummy_cell) in
  let component_id = ref 0 in
  Array.iteri t.nodes ~f:(fun i node ->
    match node with
    | Root { rev = _ } ->
      let id = !component_id in
      Int.incr component_id;
      components.(i) <- Union_find.create id
    | Commit { rev = _; parent } -> components.(i) <- components.(parent)
    | Merge { rev = _; parent1; parent2 } ->
      let component1 = components.(parent1) in
      Union_find.union component1 components.(parent2);
      components.(i) <- component1);
  let num_id = !component_id in
  let logs = Array.init num_id ~f:(fun _ -> Queue.create ()) in
  let refs = Array.init num_id ~f:(fun _ -> Queue.create ()) in
  Array.iteri components ~f:(fun i cell ->
    let id = Union_find.get cell in
    Queue.enqueue
      logs.(id)
      (Node_kind.to_log_line t.nodes.(i) ~f:(fun i -> Node_kind.rev t.nodes.(i))));
  Hashtbl.iteri t.refs ~f:(fun ~key:ref_kind ~data:index ->
    let id = Union_find.get components.(index) in
    Queue.enqueue refs.(id) { Refs.Line.rev = Node_kind.rev t.nodes.(index); ref_kind });
  Array.map2_exn logs refs ~f:(fun log refs ->
    { Subtree.log = Queue.to_list log; refs = Queue.to_list refs })
  |> Array.filter ~f:(fun subtree -> not (Subtree.is_empty subtree))
  |> Array.to_list
;;

module Summary = struct
  [@@@coverage off]

  type t =
    { refs : (Rev.t * string) list
    ; roots : Rev.t list
    ; tips : (Rev.t * string list) list
    ; subtrees : t list [@sexp_drop_if List.is_empty]
    }
  [@@deriving sexp_of]
end

let rec summary t =
  let refs =
    List.map (refs t) ~f:(fun { Refs.Line.rev; ref_kind } ->
      rev, Ref_kind.to_string ref_kind)
  in
  let tips =
    List.map (tips t) ~f:(fun node ->
      Node.rev t node, Node.refs t node |> List.map ~f:Ref_kind.to_string)
  in
  let subtrees =
    match subtrees t with
    | [] | [ _ ] -> []
    | subtrees -> List.map subtrees ~f:(fun subtree -> summary (of_subtree subtree))
  in
  { Summary.refs
  ; roots = roots t |> List.map ~f:(fun id -> Node.rev t id)
  ; tips
  ; subtrees
  }
;;
