(** Writing to a [Eio.Buf_write.t] with an api that resembles [Stdio] or
    [Async.Writer]. *)

type t = Eio.Buf_write.t

(** Same as [Eio.Buf_write.with_flow]. *)
val with_flow : ?initial_size:int -> _ Eio.Flow.sink -> (t -> 'a) -> 'a

(** {1 Async writer style API}

    In this API, the emphasis is put on the prefix "write", rather than "print".
    "Print" sounds a bit like this is printing to the screen or the terminal, so
    it is reserved to the part of the API that prints to the standard channels
    (see below). *)

val write_string : t -> ?pos:int -> ?len:int -> string -> unit
val write_newline : t -> unit
val write_line : t -> string -> unit
val write_lines : t -> string list -> unit

(** Write a sexp followed by a newline character. Default to [mach:false], which
    means uses [Sexp.to_string_hum] by default.*)
val write_sexp : ?mach:bool -> t -> Sexp.t -> unit

val writef : t -> ('a, Stdlib.Format.formatter, unit) format -> 'a
val flush : t -> unit

(** {1 Stdio style API}

    There are cases where just need to print a quick statement to stdout or
    stderr, and going through building a complete call to {!with_flow} feels too
    heavy. We assume that these functions are primarily useful in context where
    you have access to the eio env. The name exposed below are derived from
    OCaml's stdlib, and are good candidate for easily migrating some code. *)

val print_string
  :  env:< stdout : [> Eio.Flow.sink_ty ] Eio.Resource.t ; .. >
  -> string
  -> unit

val print_endline
  :  env:< stdout : [> Eio.Flow.sink_ty ] Eio.Resource.t ; .. >
  -> string
  -> unit

val print_newline : env:< stdout : [> Eio.Flow.sink_ty ] Eio.Resource.t ; .. > -> unit

(** Write all strings in the order supplied to stdout, each followed by a newline char. *)
val print_lines
  :  env:< stdout : [> Eio.Flow.sink_ty ] Eio.Resource.t ; .. >
  -> string list
  -> unit

val prerr_string
  :  env:< stderr : [> Eio.Flow.sink_ty ] Eio.Resource.t ; .. >
  -> string
  -> unit

val prerr_endline
  :  env:< stderr : [> Eio.Flow.sink_ty ] Eio.Resource.t ; .. >
  -> string
  -> unit

val prerr_newline : env:< stderr : [> Eio.Flow.sink_ty ] Eio.Resource.t ; .. > -> unit

(** {2 Format} *)

val printf
  :  env:< stdout : [> Eio.Flow.sink_ty ] Eio.Resource.t ; .. >
  -> ('a, unit, string, unit) format4
  -> 'a

val aprintf
  :  env:< stdout : [> Eio.Flow.sink_ty ] Eio.Resource.t ; .. >
  -> ('a, Stdlib.Format.formatter, unit) format
  -> 'a

val eprintf
  :  env:< stderr : [> Eio.Flow.sink_ty ] Eio.Resource.t ; .. >
  -> ('a, unit, string, unit) format4
  -> 'a

(** {2 Sexp} *)

(** Print a sexp followed by a newline character. See [Stdio.print_s]. Default
    to [mach:false], which means uses [Sexp.to_string_hum] by default. *)
val print_sexp
  :  env:< stdout : [> Eio.Flow.sink_ty ] Eio.Resource.t ; .. >
  -> ?mach:bool
  -> Sexp.t
  -> unit
