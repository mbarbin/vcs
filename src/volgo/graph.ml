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

module Node = struct
  type t = int

  let compare = Int.compare
  let equal = Int.equal
  let hash = Int.hash
  let seeded_hash = Int.seeded_hash
  let sexp_of_t i = Sexp.Atom ("#" ^ Int.to_string_hum i)
end

module Node_kind = struct
  module T = struct
    [@@@coverage off]

    type t =
      | Root of { rev : Rev.t }
      | Commit of
          { rev : Rev.t
          ; parent : Node.t
          }
      | Merge of
          { rev : Rev.t
          ; parent1 : Node.t
          ; parent2 : Node.t
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
           let arg__008_ = Node.sexp_of_t parent__007_ in
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
           let arg__015_ = Node.sexp_of_t parent2__014_ in
           (Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "parent2"; arg__015_ ] :: bnds__009_
            : _ Stdlib.List.t)
         in
         let bnds__009_ =
           let arg__013_ = Node.sexp_of_t parent1__012_ in
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
             && Node.equal _a__005_.parent _b__006_.parent
           | Commit _, _ -> false
           | _, Commit _ -> false
           | Merge _a__007_, Merge _b__008_ ->
             Rev.equal _a__007_.rev _b__008_.rev
             && Node.equal _a__007_.parent1 _b__008_.parent1
             && Node.equal _a__007_.parent2 _b__008_.parent2)
       : t -> t -> bool)
    ;;
  end

  include T

  let rev = function
    | Root { rev } -> rev
    | Commit { rev; _ } -> rev
    | Merge { rev; _ } -> rev
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

  module Nodes = struct
    type t = Node_kind.t array

    let sexp_of_t t =
      t
      |> Array.mapi ~f:(fun node node_kind ->
        Sexp.List [ node |> Node.sexp_of_t; node_kind |> Node_kind.sexp_of_t ])
      |> Array.rev
      |> Array.sexp_of_t Fun.id
    ;;
  end

  module Revs = struct
    type t = int Rev_table.t

    let sexp_of_t (t : t) =
      let revs = Rev_table.to_seq t |> Array.of_seq in
      Array.sort revs ~compare:(fun (_, n1) (_, n2) -> Int.compare n2 n1);
      revs
      |> Array.sexp_of_t (fun (rev, index) ->
        Sexp.List [ index |> Node.sexp_of_t; rev |> Rev.sexp_of_t ])
    ;;
  end

  module Reverse_refs = struct
    type t = Ref_kind.t list Int_table.t

    let sexp_of_t (t : t) =
      let revs =
        Int_table.to_seq t
        |> Array.of_seq
        |> Array.map ~f:(fun (n, refs) -> n, List.sort refs ~compare:Ref_kind.compare)
      in
      Array.sort revs ~compare:(fun (n1, _) (n2, _) -> Int.compare n2 n1);
      revs
      |> Array.sexp_of_t (fun (node, ref_kinds) ->
        Sexp.List
          [ node |> Node.sexp_of_t; ref_kinds |> List.sexp_of_t Ref_kind.sexp_of_t ])
    ;;
  end

  type t =
    { mutable nodes : Nodes.t
    ; revs : int Rev_table.t
    ; refs : int Ref_kind_table.t
    ; reverse_refs : Ref_kind.t list Int_table.t
    }

  let sexp_of_t { nodes; revs; refs = _; reverse_refs } =
    Sexp.List
      [ sexp_field (module Nodes) "nodes" nodes
      ; sexp_field (module Revs) "revs" revs
      ; sexp_field (module Reverse_refs) "refs" reverse_refs
      ]
  ;;
end

include T

let create () =
  let init = 37 in
  { nodes = [||]
  ; revs = Rev_table.create init
  ; refs = Ref_kind_table.create init
  ; reverse_refs = Int_table.create init
  }
;;

let node_count t = Array.length t.nodes
let node_kind t ~node = t.nodes.(node)
let ( .$() ) t node = node_kind t ~node
let rev t ~node = Node_kind.rev t.$(node)

let parents t ~node =
  match t.$(node) with
  | Node_kind.Root _ -> []
  | Commit { parent; _ } -> [ parent ]
  | Merge { parent1; parent2; _ } -> [ parent1; parent2 ]
;;

let prepend_parents t ~node ~prepend_to:list =
  match t.$(node) with
  | Node_kind.Root _ -> list
  | Commit { parent; _ } -> parent :: list
  | Merge { parent1; parent2; _ } -> parent1 :: parent2 :: list
;;

let node_refs t ~node =
  Int_table.find t.reverse_refs node
  |> Option.value ~default:[]
  |> List.sort ~compare:Ref_kind.compare
;;

let log_line t ~node = Node_kind.to_log_line t.$(node) ~f:(fun i -> Node_kind.rev t.$(i))

(* Helper function to iter over all ancestors of a given node, itself included.
   [visited] is taken as an input so we can re-use the same array multiple
   times, rather than re-allocating it. *)
let iter_ancestors t ~visited node ~f =
  let rec loop = function
    | [] -> ()
    | node :: to_visit ->
      let to_visit =
        if Bitv.get visited node
        then to_visit
        else (
          Bitv.set visited node true;
          f node;
          prepend_parents t ~node ~prepend_to:to_visit)
      in
      loop to_visit
  in
  loop [ node ]
;;

let greatest_common_ancestors t ~nodes =
  match nodes with
  | [] -> []
  | [ node ] -> [ node ]
  | node1 :: nodes ->
    let node_count = Array.length t.nodes in
    let common_ancestors =
      let node1_ancestors = Bitv.create node_count false in
      iter_ancestors t ~visited:node1_ancestors node1 ~f:(fun _ -> ());
      node1_ancestors
    in
    let visited = Bitv.create node_count false in
    List.iter nodes ~f:(fun node ->
      iter_ancestors t ~visited node ~f:(fun _ -> ());
      Bitv.bw_and_in_place ~dst:common_ancestors common_ancestors visited;
      Bitv.fill visited 0 (Bitv.length visited) false);
    let gcas = ref [] in
    for i = node_count - 1 downto 0 do
      if Bitv.get common_ancestors i
      then (
        gcas := i :: !gcas;
        iter_ancestors t ~visited i ~f:(fun j ->
          if j <> i then Bitv.set common_ancestors j false))
    done;
    !gcas
;;

let refs t =
  Ref_kind_table.to_seq t.refs
  |> List.of_seq
  |> List.sort ~compare:(fun (r1, _) (r2, _) -> Ref_kind.compare r1 r2)
  |> List.map ~f:(fun (ref_kind, index) ->
    { Refs.Line.rev = Node_kind.rev t.$(index); ref_kind })
;;

let set_ref t ~rev ~ref_kind =
  match Rev_table.find t.revs rev with
  | None -> Err.raise [ Pp.text "Rev not found."; Err.sexp (rev |> Rev.sexp_of_t) ]
  | Some index ->
    (match Ref_kind_table.find t.refs ref_kind with
     | None -> ()
     | Some previous_node ->
       (match Int_table.find t.reverse_refs previous_node with
        | None -> assert false (* Inconsistency between [t.refs] and [t.reverse_refs]. *)
        | Some refs ->
          let refs = List.filter refs ~f:(fun r -> not (Ref_kind.equal r ref_kind)) in
          if List.is_empty refs
          then Int_table.remove t.reverse_refs previous_node
          else Int_table.set t.reverse_refs ~key:previous_node ~data:refs));
    Ref_kind_table.set t.refs ~key:ref_kind ~data:index;
    Int_table.add_multi t.reverse_refs ~key:index ~data:ref_kind
;;

let set_refs t ~refs =
  List.iter refs ~f:(fun { Refs.Line.rev; ref_kind } -> set_ref t ~rev ~ref_kind)
;;

let find_ref t ~ref_kind = Ref_kind_table.find t.refs ref_kind
let mem_rev t ~rev = Rev_table.mem t.revs rev
let find_rev t ~rev = Rev_table.find t.revs rev

let add_nodes t ~log =
  let line_count = List.length log in
  let nodes_table =
    let table = Rev_table.create line_count in
    List.iter log ~f:(fun line ->
      Rev_table.add_exn table ~key:(Log.Line.rev line) ~data:line);
    table
  in
  let new_nodes = Queue.create () in
  let visited = Rev_table.create line_count in
  let is_visited rev =
    if Rev_table.mem visited rev
    then true
    else if mem_rev t ~rev
    then (
      Rev_table.add visited ~key:rev ~data:();
      true)
    else false
  in
  let rec visit (line : Log.Line.t) =
    let find_parent parent =
      match Rev_table.find nodes_table parent with
      | Some node -> node
      | None ->
        Err.raise
          [ Pp.text "Parent not found."; Err.sexp (line |> Log.Line.sexp_of_t) ]
        [@coverage off]
    in
    match (line : Log.Line.t) with
    | Root { rev } ->
      if not (is_visited rev)
      then (
        Rev_table.add visited ~key:rev ~data:();
        Queue.enqueue new_nodes line)
    | Commit { rev; parent } ->
      if not (is_visited rev)
      then (
        Rev_table.add visited ~key:rev ~data:();
        if not (Rev_table.mem t.revs parent) then visit (find_parent parent);
        Queue.enqueue new_nodes line)
    | Merge { rev; parent1; parent2 } ->
      if not (is_visited rev)
      then (
        Rev_table.add visited ~key:rev ~data:();
        if not (Rev_table.mem t.revs parent1) then visit (find_parent parent1);
        if not (Rev_table.mem t.revs parent2) then visit (find_parent parent2);
        Queue.enqueue new_nodes line)
  in
  (* We iter in reverse order to makes the depth of visited path shorter. *)
  List.iter (List.rev log) ~f:visit;
  let new_index = Array.length t.nodes in
  let new_nodes =
    let find_node_exn rev =
      match Rev_table.find t.revs rev with
      | Some node -> node
      | None ->
        Err.raise
          [ Pp.text "Node not found during the building of new nodes (internal error)."
          ; Err.sexp (sexp_field (module Rev) "rev" rev)
          ] [@coverage off]
    in
    Queue.to_seq new_nodes
    |> Array.of_seq
    |> Array.mapi ~f:(fun i node ->
      let index = new_index + i in
      let rev = Log.Line.rev node in
      Rev_table.add_exn t.revs ~key:rev ~data:index;
      match node with
      | Root _ -> Node_kind.Root { rev }
      | Commit { rev; parent; _ } ->
        Node_kind.Commit { rev; parent = find_node_exn parent }
      | Merge { rev; parent1; parent2; _ } ->
        Node_kind.Merge
          { rev; parent1 = find_node_exn parent1; parent2 = find_node_exn parent2 })
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

(* Pre condition: ancestor < descendant. *)
let is_strict_ancestor_internal t ~ancestor ~descendant =
  assert (ancestor < descendant);
  let visited = Bitv.create (descendant - ancestor + 1) false in
  let rec loop = function
    | [] -> false
    | node :: to_visit ->
      (match Int.compare ancestor node |> Ordering.of_int with
       | Eq -> true
       | Gt -> loop to_visit
       | Lt ->
         let to_visit =
           let visited_index = node - ancestor in
           if Bitv.get visited visited_index
           then to_visit
           else (
             Bitv.set visited visited_index true;
             prepend_parents t ~node ~prepend_to:to_visit)
         in
         loop to_visit)
  in
  loop [ descendant ]
;;

let is_strict_ancestor t ~ancestor ~descendant =
  ancestor < descendant && is_strict_ancestor_internal t ~ancestor ~descendant
;;

let is_ancestor_or_equal t ~ancestor ~descendant =
  ancestor = descendant || is_strict_ancestor t ~ancestor ~descendant
;;

module Descendance = struct
  [@@@coverage off]

  type t =
    | Same_node
    | Strict_ancestor
    | Strict_descendant
    | Other
  [@@deriving_inline enumerate, sexp_of]

  let all = ([ Same_node; Strict_ancestor; Strict_descendant; Other ] : t list)

  let sexp_of_t =
    (function
     | Same_node -> Sexplib0.Sexp.Atom "Same_node"
     | Strict_ancestor -> Sexplib0.Sexp.Atom "Strict_ancestor"
     | Strict_descendant -> Sexplib0.Sexp.Atom "Strict_descendant"
     | Other -> Sexplib0.Sexp.Atom "Other"
     : t -> Sexplib0.Sexp.t)
  ;;

  [@@@deriving.end]

  let compare = (compare : t -> t -> int)
  let equal = (( = ) : t -> t -> bool)
  let seeded_hash = (Hashtbl.seeded_hash : int -> t -> int)
  let hash = (Hashtbl.hash : t -> int)
end

let descendance t a b : Descendance.t =
  match Int.compare a b |> Ordering.of_int with
  | Eq -> Same_node
  | Lt ->
    if is_strict_ancestor_internal t ~ancestor:a ~descendant:b
    then Strict_ancestor
    else Other
  | Gt ->
    if is_strict_ancestor_internal t ~ancestor:b ~descendant:a
    then Strict_descendant
    else Other
;;

let leaves t =
  let has_children = Bitv.create (node_count t) false in
  Array.iter t.nodes ~f:(fun node ->
    match (node : Node_kind.t) with
    | Root _ -> ()
    | Commit { parent; _ } -> Bitv.set has_children parent true
    | Merge { parent1; parent2; _ } ->
      Bitv.set has_children parent1 true;
      Bitv.set has_children parent2 true);
  Array.filter_mapi t.nodes ~f:(fun i _ ->
    if Bitv.get has_children i then None else Some i)
  |> Array.to_list
;;

let log t = Array.mapi t.nodes ~f:(fun node _ -> log_line t ~node) |> Array.to_list

module Subgraph = struct
  module T = struct
    [@@@coverage off]

    type t =
      { log : Log.t
      ; refs : Refs.t
      }
    [@@deriving_inline sexp_of]

    let sexp_of_t =
      (fun { log = log__017_; refs = refs__019_ } ->
         let bnds__016_ = ([] : _ Stdlib.List.t) in
         let bnds__016_ =
           let arg__020_ = Refs.sexp_of_t refs__019_ in
           (Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "refs"; arg__020_ ] :: bnds__016_
            : _ Stdlib.List.t)
         in
         let bnds__016_ =
           let arg__018_ = Log.sexp_of_t log__017_ in
           (Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "log"; arg__018_ ] :: bnds__016_
            : _ Stdlib.List.t)
         in
         Sexplib0.Sexp.List bnds__016_
       : t -> Sexplib0.Sexp.t)
    ;;

    [@@@deriving.end]
  end

  include T

  let is_empty { log; refs } = List.is_empty log && List.is_empty refs
end

let of_subgraph { Subgraph.log; refs } =
  let t = create () in
  add_nodes t ~log;
  set_refs t ~refs;
  t
;;

(* In [subgraphs] we are using what is conceptually an union-find algorithm.
   Each commit is attached to a representative for the subgraph it belongs to.
   Unique representatives are created for every root node. We perform an union
   of representatives during the processing of merge nodes. Because of the
   specific nature of how we represent graphs here, we get away with a
   simplified union-find. Indeed, all the union-find paths that are manipulated
   are always in "compressed" form, and thus we can simply use ordinary
   references rather than compressible union-find nodes. *)
let subgraphs t =
  let dummy_cell = ref (-1) in
  let components = Array.map t.nodes ~f:(fun _ -> dummy_cell) in
  let component_id = ref 0 in
  Array.iteri t.nodes ~f:(fun i node ->
    let representative =
      match (node : Node_kind.t) with
      | Root { rev = _ } ->
        (* Mint a new representative. *)
        let id = component_id.contents in
        Int.incr component_id;
        ref id
      | Commit { rev = _; parent } ->
        (* Reuse an existing representative. *)
        components.(parent)
      | Merge { rev = _; parent1; parent2 } ->
        (* Keep component1 as representative for the union of 2 nodes. *)
        let component1 = components.(parent1) in
        components.(parent2).contents <- component1.contents;
        component1
    in
    components.(i) <- representative);
  (* In the general case, [num_id] is greater than the actual number of
     resulting subgraphs. The subgraphs that correspond to the component ids
     that were not kept as representatives during the processing of [Merge]
     nodes are going to be empty at the end, and we filter them out. *)
  let num_id = component_id.contents in
  let logs = Array.init num_id ~f:(fun _ -> Queue.create ()) in
  let refs = Array.init num_id ~f:(fun _ -> Queue.create ()) in
  Array.iteri components ~f:(fun i cell ->
    let id = cell.contents in
    Queue.enqueue logs.(id) (log_line t ~node:i));
  Ref_kind_table.iter t.refs ~f:(fun ~key:ref_kind ~data:index ->
    let id = components.(index).contents in
    Queue.enqueue refs.(id) { Refs.Line.rev = Node_kind.rev t.$(index); ref_kind });
  Array.map2 logs refs ~f:(fun log refs ->
    { Subgraph.log = Queue.to_list log; refs = Queue.to_list refs })
  |> Array.to_list
  |> List.filter ~f:(fun subgraph -> not (Subgraph.is_empty subgraph))
;;

module Summary = struct
  [@@@coverage off]

  type t =
    { refs : (Rev.t * string) list
    ; roots : Rev.t list
    ; leaves : (Rev.t * string list) list
    ; subgraphs : t list [@sexp_drop_if List.is_empty]
    }
  [@@deriving_inline sexp_of]

  let rec sexp_of_t =
    (let (drop_if__037_ : t list -> Stdlib.Bool.t) = List.is_empty in
     fun { refs = refs__022_
         ; roots = roots__028_
         ; leaves = leaves__030_
         ; subgraphs = subgraphs__038_
         } ->
       let bnds__021_ = ([] : _ Stdlib.List.t) in
       let bnds__021_ =
         if drop_if__037_ subgraphs__038_
         then bnds__021_
         else (
           let arg__040_ = (sexp_of_list sexp_of_t) subgraphs__038_ in
           let bnd__039_ =
             Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "subgraphs"; arg__040_ ]
           in
           (bnd__039_ :: bnds__021_ : _ Stdlib.List.t))
       in
       let bnds__021_ =
         let arg__031_ =
           sexp_of_list
             (fun (arg0__032_, arg1__033_) ->
                let res0__034_ = Rev.sexp_of_t arg0__032_
                and res1__035_ = sexp_of_list sexp_of_string arg1__033_ in
                Sexplib0.Sexp.List [ res0__034_; res1__035_ ])
             leaves__030_
         in
         (Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "leaves"; arg__031_ ] :: bnds__021_
          : _ Stdlib.List.t)
       in
       let bnds__021_ =
         let arg__029_ = sexp_of_list Rev.sexp_of_t roots__028_ in
         (Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "roots"; arg__029_ ] :: bnds__021_
          : _ Stdlib.List.t)
       in
       let bnds__021_ =
         let arg__023_ =
           sexp_of_list
             (fun (arg0__024_, arg1__025_) ->
                let res0__026_ = Rev.sexp_of_t arg0__024_
                and res1__027_ = sexp_of_string arg1__025_ in
                Sexplib0.Sexp.List [ res0__026_; res1__027_ ])
             refs__022_
         in
         (Sexplib0.Sexp.List [ Sexplib0.Sexp.Atom "refs"; arg__023_ ] :: bnds__021_
          : _ Stdlib.List.t)
       in
       Sexplib0.Sexp.List bnds__021_
     : t -> Sexplib0.Sexp.t)
  ;;

  [@@@deriving.end]
end

let rec summary t =
  let refs =
    List.map (refs t) ~f:(fun { Refs.Line.rev; ref_kind } ->
      rev, Ref_kind.to_string ref_kind)
  in
  let leaves =
    List.map (leaves t) ~f:(fun node ->
      rev t ~node, node_refs t ~node |> List.map ~f:Ref_kind.to_string)
  in
  let subgraphs =
    match subgraphs t with
    | [] | [ _ ] -> []
    | subgraphs -> List.map subgraphs ~f:(fun subgraph -> summary (of_subgraph subgraph))
  in
  { Summary.refs
  ; roots = roots t |> List.map ~f:(fun id -> rev t ~node:id)
  ; leaves
  ; subgraphs
  }
;;

let check_index_exn t ~index =
  let node_count = node_count t in
  if index < 0 || index >= node_count
  then
    Err.raise
      [ Pp.text "Node index out of bounds."
      ; Err.sexp
          (List
             [ sexp_field (module Int) "index" index
             ; sexp_field (module Int) "node_count" node_count
             ])
      ]
;;

let get_node_exn t ~index =
  check_index_exn t ~index;
  (index :> Node.t)
;;

let node_index (node : Node.t) = (node :> int)
