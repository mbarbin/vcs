module Int : sig
  include module type of Int

  val hash : t -> int
  val seeded_hash : int -> int -> int
end

module ListLabels : sig
  include module type of ListLabels

  val is_empty : _ t -> bool
end

module String : sig
  include module type of String

  val hash : t -> int
  val seeded_hash : int -> string -> int
end

module StringLabels : sig
  include module type of StringLabels

  val hash : t -> int
  val seeded_hash : int -> string -> int
end
