type t = Eio.Buf_write.t

let with_flow = Eio.Buf_write.with_flow
let flush t = Eio.Buf_write.flush t
let write_string t ?pos ?len str = Eio.Buf_write.string t ?off:pos ?len str
let write_newline t = write_string t "\n"

let write_line t str =
  write_string t str;
  write_newline t
;;

let writef t fmt = Eio.Buf_write.printf t fmt
let write_lines t lines = List.iter lines ~f:(fun line -> write_line t line)

let write_sexp ?(mach = false) t sexp =
  write_line t (if mach then Sexp.to_string_mach sexp else Sexp.to_string_hum sexp)
;;

let print_string ~env str =
  with_flow (Eio.Stdenv.stdout env) (fun t -> write_string t str)
;;

let print_newline ~env = print_string ~env "\n"
let print_endline ~env str = with_flow (Eio.Stdenv.stdout env) (fun t -> write_line t str)

let print_lines ~env lines =
  with_flow (Eio.Stdenv.stdout env) (fun t ->
    List.iter lines ~f:(fun line -> write_line t line))
;;

let print_sexp ~env ?mach sexp =
  with_flow (Eio.Stdenv.stdout env) (fun t -> write_sexp ?mach t sexp)
;;

let prerr_string ~env str =
  with_flow (Eio.Stdenv.stderr env) (fun t -> write_string t str)
;;

let prerr_newline ~env = prerr_string ~env "\n"
let prerr_endline ~env str = with_flow (Eio.Stdenv.stderr env) (fun t -> write_line t str)
let printf ~env fmt = Printf.ksprintf (fun str -> print_string ~env str) fmt
let aprintf ~env fmt = Stdlib.Format.kasprintf (fun str -> print_string ~env str) fmt
let eprintf ~env fmt = Printf.ksprintf (fun str -> prerr_string ~env str) fmt
