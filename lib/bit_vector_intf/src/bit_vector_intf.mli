module type S = sig
  type t

  val sexp_of_t : t -> Sexplib0.Sexp.t
  val create : len:int -> bool -> t
  val length : t -> int
  val set : t -> int -> bool -> unit
  val get : t -> int -> bool
  val reset : t -> bool -> unit
  val copy : t -> t

  (** {1 In place bitwise operations} *)

  val bw_and_in_place : dest:t -> t -> t -> unit
end
