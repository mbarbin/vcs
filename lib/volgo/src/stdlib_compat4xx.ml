module Int = struct
  include Int

  let hash : int -> int = Hashtbl.hash
  let seeded_hash : int -> int -> int = Hashtbl.seeded_hash
end

module ListLabels = struct
  include ListLabels

  let is_empty = function
    | [] -> true
    | _ :: _ -> false
  ;;
end

module String = struct
  include String

  let hash : string -> int = Hashtbl.hash
  let seeded_hash : int -> string -> int = Hashtbl.seeded_hash
end

module StringLabels = struct
  include StringLabels

  let hash : string -> int = Hashtbl.hash
  let seeded_hash : int -> string -> int = Hashtbl.seeded_hash
end
