include Expect_test_helpers_base_intf

let print_string string =
  print_string string;
  Out_channel.(flush stdout)
;;

module CR = struct
  include CR

  let message t here =
    let cr cr =
      String.concat
        [ "(* "
        ; cr
        ; " require-failed: "
        ; here |> Source_code_position.to_string
        ; ".\n"
        ; "   Do not 'X' this CR; instead make the required property true,\n"
        ; "   which will make the CR disappear.  For more information, see\n"
        ; "   [Expect_test_helpers_base.require]. *)"
        ]
    in
    match t with
    | CR -> cr "CR"
    | CR_soon -> cr "CR-soon"
    | CR_someday -> cr "CR-someday"
    | Comment ->
      String.concat
        [ "(* require-failed: "; here |> Source_code_position.to_string; ". *)" ]
    | Suppress -> ""
  ;;

  let hide_unstable_output = function
    | CR -> false
    | CR_soon | CR_someday | Comment | Suppress -> true
  ;;
end

module Sexp_style = struct
  include Sexp_style

  let default_pretty = Pretty (Sexp_pretty.Config.create ~color:false ())

  let simple_pretty =
    Pretty
      { indent = 1
      ; data_alignment = Data_not_aligned
      ; color_scheme = [||]
      ; atom_coloring = Color_none
      ; atom_printing = Escaped
      ; paren_coloring = false
      ; opening_parens = Same_line
      ; closing_parens = Same_line
      ; comments = Drop
      ; singleton_limit = Singleton_limit (Atom_threshold 0, Character_threshold 0)
      ; leading_threshold = Atom_threshold 0, Character_threshold 0
      ; separator = No_separator
      ; sticky_comments = After
      }
  ;;
end

module Phys_equal (M : sig
    type t [@@deriving sexp_of]
  end) =
struct
  type t = M.t [@@deriving sexp_of]

  let equal = phys_equal
end

let hide_temp_files_in_string =
  let re = lazy (Re.compile (Re.seq [ Re.str ".tmp."; Re.repn Re.alnum 6 (Some 6) ])) in
  fun string -> Re.replace_string (force re) ~by:".tmp.RANDOM" string
;;

let hide_positions_in_string =
  let module Re = Re.Pcre in
  let expanders =
    lazy
      ([ (* This first pattern has an alphabetic prefix because we want to match exceptions
            and their file positions without also matching timestamps.  However, [Re.Pcre]
            doesn't implement back-references, precluding a simple substitution.  Instead,
            we provide a length of matched data to copy into the output, effectively acting
            like a back-reference in this special case. *)
         "[a-zA-z]:[0-9]+:[0-9]+", 1, ":LINE:COL"
       ; "line [0-9]+:", 0, "line LINE:"
       ; "line [0-9]+, characters [0-9]+-[0-9]+", 0, "line LINE, characters C1-C2"
       ]
       |> List.map ~f:(fun (pattern, prefix_len, expansion) ->
         let rex = Re.regexp pattern in
         fun string ->
           Re.substitute ~rex string ~subst:(fun orig ->
             String.concat [ String.prefix orig prefix_len; expansion ])))
  in
  fun string ->
    List.fold (force expanders) ~init:string ~f:(fun ac expander -> expander ac)
;;

let maybe_hide_positions_in_string ?(hide_positions = false) string =
  if hide_positions then hide_positions_in_string string else string
;;

let sexp_style = ref Sexp_style.default_pretty

let sexp_to_string ?hide_positions sexp =
  let string =
    match !sexp_style with
    | To_string_mach -> Sexp.to_string_mach sexp ^ "\n"
    | To_string_hum -> Sexp.to_string_hum sexp ^ "\n"
    | Pretty config -> Sexp_pretty.pretty_string config sexp
  in
  maybe_hide_positions_in_string ?hide_positions string
;;

let replace = String.substr_replace_all

let rec replace_s (sexp : Sexp.t) ~pattern ~with_ : Sexp.t =
  match sexp with
  | Atom atom -> Atom (replace atom ~pattern ~with_)
  | List list -> List (List.map list ~f:(replace_s ~pattern ~with_))
;;

let expect_test_output (here : Lexing.position) =
  Ppx_expect_runtime.For_external.read_current_test_output_exn ~here
;;

let am_running_expect_test = Ppx_expect_runtime.For_external.am_running_expect_test

let assert_am_running_expect_test here =
  if am_running_expect_test ()
  then ()
  else
    raise_s
      [%message
        "This code should be run inside an expect test; currently, it is running outside \
         an expect test."
          ~_:(here : Source_code_position.t)]
;;

let wrap f =
  Staged.stage (fun ?hide_positions string ->
    f (maybe_hide_positions_in_string ?hide_positions string))
;;

let rec smash_sexp sexp ~f =
  match f sexp with
  | Sexp.List list -> Sexp.List (List.map list ~f:(smash_sexp ~f))
  | Sexp.Atom _ as atom -> atom
;;

let remove_backtraces =
  let prefixes =
    List.concat
      [ (* taken from [printexc.ml] in ocaml runtime *)
        [ "Raised at "
        ; "Re-raised at "
        ; "Raised by primitive operation at "
        ; "Called from "
        ]
        (* based on [monitor.ml] in async_kernel *)
      ; [ "Caught by monitor " ]
      ]
  in
  smash_sexp ~f:(function
    | Sexp.(List (Atom hd :: _))
      when List.exists prefixes ~f:(fun prefix -> String.is_prefix ~prefix hd) ->
      Sexp.(List [ Atom "ELIDED BACKTRACE" ])
    | s -> s)
;;

let print_endline = Staged.unstage (wrap print_endline)
let print_string = Staged.unstage (wrap print_string)
let print_s ?hide_positions sexp = print_string (sexp_to_string ?hide_positions sexp)
let on_print_cr = ref (fun string -> print_endline string)

let print_cr_with_optional_message
  ?(cr = CR.CR)
  ?(hide_positions = CR.hide_unstable_output cr)
  here
  optional_message
  =
  assert_am_running_expect_test here;
  match cr with
  | Suppress -> ()
  | _ ->
    let cr = CR.message cr here |> maybe_hide_positions_in_string ~hide_positions in
    !on_print_cr
      (match optional_message with
       | None -> cr
       | Some sexp ->
         String.concat [ cr; "\n"; String.rstrip (sexp_to_string ~hide_positions sexp) ])
;;

let print_cr ?cr ?hide_positions here message =
  print_cr_with_optional_message ?cr ?hide_positions here (Some message)
;;

let require ?cr ?hide_positions ?if_false_then_print_s here bool =
  match bool with
  | true -> ()
  | false ->
    print_cr_with_optional_message
      ?cr
      ?hide_positions
      here
      (Option.map if_false_then_print_s ~f:force)
;;

let require_equal
  (type a)
  ?cr
  ?hide_positions
  ?if_false_then_print_s
  ?(message = "values are not equal")
  here
  (module M : With_equal with type t = a)
  x
  y
  =
  require
    ?cr
    ?hide_positions
    here
    (M.equal x y)
    ~if_false_then_print_s:
      (lazy
        [%message
          message
            ~_:(x : M.t)
            ~_:(y : M.t)
            ~_:(if_false_then_print_s : (Sexp.t Lazy.t option[@sexp.option]))])
;;

let require_not_equal
  (type a)
  ?cr
  ?hide_positions
  ?if_false_then_print_s
  ?(message = "values are equal")
  here
  (module M : With_equal with type t = a)
  x
  y
  =
  require
    ?cr
    ?hide_positions
    here
    (not (M.equal x y))
    ~if_false_then_print_s:
      (lazy
        [%message
          message
            ~_:(x : M.t)
            ~_:(y : M.t)
            ~_:(if_false_then_print_s : (Sexp.t Lazy.t option[@sexp.option]))])
;;

let require_compare_equal
  (type a)
  ?cr
  ?hide_positions
  ?message
  here
  (module M : With_compare with type t = a)
  x
  y
  =
  require_equal
    ?cr
    ?hide_positions
    ?message
    here
    (module struct
      include M

      let equal = [%compare.equal: t]
    end)
    x
    y
;;

let require_compare_not_equal
  (type a)
  ?cr
  ?hide_positions
  ?message
  here
  (module M : With_compare with type t = a)
  x
  y
  =
  require_not_equal
    ?cr
    ?hide_positions
    ?message
    here
    (module struct
      include M

      let equal = [%compare.equal: t]
    end)
    x
    y
;;

let require_sets_are_equal
  (type elt)
  ?cr
  ?hide_positions
  ?(names = "first", "second")
  here
  first
  second
  =
  let module Elt = struct
    type t = elt

    let sexp_of_t = (Set.comparator first).sexp_of_t
  end
  in
  require
    ?cr
    ?hide_positions
    here
    (Set.equal first second)
    ~if_false_then_print_s:
      (lazy
        (let show_diff (name1, set1) (name2, set2) =
           let diff = Set.diff set1 set2 in
           if Set.is_empty diff
           then [%message]
           else
             [%message
               (Printf.sprintf "in %s but not in %s" name1 name2) ~_:(diff : Set.M(Elt).t)]
         in
         let first = fst names, first in
         let second = snd names, second in
         [%message.omit_nil
           "sets are not equal"
             ~_:(show_diff first second : Sexp.t)
             ~_:(show_diff second first : Sexp.t)]))
;;

type try_with_result =
  | Did_not_raise
  | Raised of Sexp.t

let try_with ?raise_message ?(show_backtrace = false) (type a) (f : unit -> a) =
  (Backtrace.Exn.with_recording show_backtrace ~f:(fun () ->
     match ignore (f () : a) with
     | () -> Did_not_raise
     | exception exn ->
       let backtrace =
         if not show_backtrace then None else Some (Backtrace.Exn.most_recent ())
       in
       Ref.set_temporarily Backtrace.elide (not show_backtrace) ~f:(fun () ->
         Raised
           [%message
             ""
               ~_:(raise_message : (string option[@sexp.option]))
               ~_:(exn : exn)
               (backtrace : (Backtrace.t option[@sexp.option]))])) [@nontail])
;;

let require_does_not_raise ?cr ?hide_positions ?show_backtrace here f =
  match try_with f ?show_backtrace ~raise_message:"unexpectedly raised" with
  | Did_not_raise -> ()
  | Raised message -> print_cr ?cr ?hide_positions here message
;;

let require_does_raise ?cr ?(hide_positions = false) ?show_backtrace here f =
  match try_with f ?show_backtrace with
  | Raised message -> print_s ~hide_positions message
  | Did_not_raise -> print_cr ?cr ~hide_positions here [%message "did not raise"]
;;

let require_first_gen
  (type first second)
  ?cr
  ?hide_positions
  ?(print_first : (first -> Sexp.t) option)
  ~message
  here
  (sexp_of_second : second -> Sexp.t)
  (either : (first, second) Either.t)
  =
  match either with
  | First first ->
    (match print_first with
     | None -> ()
     | Some sexp_of_first -> print_s [%sexp (first : first)])
  | Second second ->
    print_cr ?cr ?hide_positions here [%message message ~_:(second : second)]
;;

let require_first = require_first_gen ~message:"unexpected [Second]"

let require_second ?cr ?hide_positions ?print_second here print_first either =
  require_first_gen
    ?cr
    ?hide_positions
    ?print_first:print_second
    ~message:"unexpected [First]"
    here
    print_first
    (Either.swap either)
;;

let require_some ?cr ?hide_positions ?print_some here option =
  require_first_gen
    ?cr
    ~message:"unexpected [None]"
    ?hide_positions
    ?print_first:print_some
    here
    [%sexp_of: unit]
    (match option with
     | Some some -> First some
     | None -> Second ())
;;

let require_none ?cr ?hide_positions here sexp_of_some option =
  require_first_gen
    ?cr
    ~message:"unexpected [Some]"
    ?hide_positions
    here
    sexp_of_some
    (match option with
     | None -> First ()
     | Some some -> Second some)
;;

let require_ok_result ?cr ?hide_positions ?print_ok here sexp_of_error result =
  require_first_gen
    ?cr
    ~message:"unexpected [Error]"
    ?hide_positions
    ?print_first:print_ok
    here
    sexp_of_error
    (match result with
     | Ok ok -> First ok
     | Error error -> Second error)
;;

let require_error_result ?cr ?hide_positions ?print_error here sexp_of_ok result =
  require_first_gen
    ?cr
    ~message:"unexpected [Ok]"
    ?hide_positions
    ?print_first:print_error
    here
    sexp_of_ok
    (match result with
     | Error error -> First error
     | Ok ok -> Second ok)
;;

let require_ok ?cr ?hide_positions ?print_ok here res =
  require_ok_result ?cr ?hide_positions ?print_ok here [%sexp_of: Error.t] res
;;

let require_error ?cr ?hide_positions ?(print_error = false) here sexp_of_ok res =
  let print_error = Option.some_if print_error [%sexp_of: Error.t] in
  require_error_result ?cr ?hide_positions ?print_error here sexp_of_ok res
;;

let print_and_check_round_trip
  (type a)
  ?cr
  ?hide_positions
  here
  (module T : With_equal with type t = a)
  reprs
  examples
  =
  require_does_not_raise ?cr ?hide_positions here (fun () ->
    let tag_of name =
      String.map name ~f:(fun char -> if Char.is_alphanum char then char else '_')
    in
    List.iter examples ~f:(fun t ->
      (* compute conversions for each value *)
      let conversions =
        List.map reprs ~f:(fun (module M : With_round_trip with type t = a) ->
          let repr = M.to_repr t in
          let sexp = M.sexp_of_repr repr in
          let round_trip_result = M.of_repr repr in
          let name = M.repr_name in
          name, sexp, round_trip_result)
      in
      (* print one-way conversions *)
      (match conversions with
       | [] -> (* a useless case anyway *) ()
       | [ (_, sexp, _) ] ->
         (* only one repr, print unlabeled *)
         print_s sexp
       | _ :: _ :: _ ->
         (* multiple reprs, print with labels *)
         print_s
           (List
              (List.map conversions ~f:(fun (name, sexp, _) ->
                 [%sexp (tag_of name : string), (sexp : Sexp.t)]))));
      (* check two-way round-trip *)
      List.iter conversions ~f:(fun (name, sexp, round_trip) ->
        require
          ?cr
          ?hide_positions
          here
          (T.equal t round_trip)
          ~if_false_then_print_s:
            (lazy
              (Sexp.message
                 (name ^ " serialization failed to round-trip")
                 [ "original", T.sexp_of_t t
                 ; tag_of name, sexp
                 ; tag_of name ^ "_roundtrip", T.sexp_of_t round_trip
                 ])))))
;;

let print_and_check_stringable
  (type a)
  ?cr
  ?hide_positions
  here
  (module T : With_stringable with type t = a)
  list
  =
  let module T = struct
    include T

    let sexp_of_t t = Sexp.Atom (to_string t)
  end
  in
  let module Conv = struct
    type t = T.t
    type repr = string [@@deriving sexp_of]

    let to_repr = T.to_string
    let of_repr = T.of_string
    let repr_name = "string"
  end
  in
  print_and_check_round_trip ?cr ?hide_positions here (module T) [ (module Conv) ] list
;;

let print_and_check_sexpable
  (type a)
  ?cr
  ?hide_positions
  here
  (module T : With_sexpable with type t = a)
  list
  =
  let module Conv = struct
    type t = T.t
    type repr = Sexp.t [@@deriving sexp_of]

    let to_repr = T.sexp_of_t
    let of_repr = T.t_of_sexp
    let repr_name = "sexp"
  end
  in
  print_and_check_round_trip ?cr ?hide_positions here (module T) [ (module Conv) ] list
;;

let show_raise (type a) ?hide_positions ?show_backtrace (f : unit -> a) =
  print_s
    ?hide_positions
    (match try_with f ?show_backtrace ~raise_message:"raised" with
     | Did_not_raise -> [%message "did not raise"]
     | Raised message -> message)
;;

let quickcheck_m
  (type a)
  here
  ?config
  ?cr
  ?examples
  ?hide_positions
  (module M : Base_quickcheck.Test.S with type t = a)
  ~f
  =
  Base_quickcheck.Test.result
    ?config
    ?examples
    (module M)
    ~f:(fun elt ->
      let crs = Queue.create () in
      (* We set [on_print_cr] to accumulate CRs in [crs]; it affects both [f elt] as
         well as our call to [require_does_not_raise]. *)
      Ref.set_temporarily on_print_cr (Queue.enqueue crs) ~f:(fun () ->
        require_does_not_raise here ?cr ?hide_positions (fun () -> f elt));
      if Queue.is_empty crs then Ok () else Error (Queue.to_list crs))
  |> Result.iter_error ~f:(fun (input, output) ->
    print_s [%message "quickcheck: test failed" (input : M.t)];
    List.iter output ~f:print_endline)
;;

let quickcheck
  (type a)
  here
  ?cr
  ?hide_positions
  ?(seed = Base_quickcheck.Test.default_config.seed)
  ?(sizes = Base_quickcheck.Test.default_config.sizes)
  ?(trials = Base_quickcheck.Test.default_config.test_count)
  ?(shrinker = Base_quickcheck.Shrinker.atomic)
  ?(shrink_attempts = Base_quickcheck.Test.default_config.shrink_count)
  ?examples
  ~sexp_of
  ~f
  quickcheck_generator
  =
  quickcheck_m
    here
    ~config:{ seed; test_count = trials; shrink_count = shrink_attempts; sizes }
    ?cr
    ?examples
    ?hide_positions
    (module struct
      type t = a

      let sexp_of_t = sexp_of
      let quickcheck_generator = quickcheck_generator
      let quickcheck_shrinker = shrinker
    end)
    ~f
;;

module Tuple2 (M : Quickcheck.Test.S) : Quickcheck.Test.S with type t = M.t * M.t = struct
  type t = M.t * M.t [@@deriving sexp_of]

  let quickcheck_generator = [%quickcheck.generator: M.t * M.t]
  let quickcheck_shrinker = [%quickcheck.shrinker: M.t * M.t]
end

module Tuple3 (M : Quickcheck.Test.S) : Quickcheck.Test.S with type t = M.t * M.t * M.t =
struct
  type t = M.t * M.t * M.t [@@deriving sexp_of]

  let quickcheck_generator = [%quickcheck.generator: M.t * M.t * M.t]
  let quickcheck_shrinker = [%quickcheck.shrinker: M.t * M.t * M.t]
end

let test_compare here ?config ?cr ?hide_positions (module M : With_quickcheck_and_compare)
  =
  let check bool msg = require here ?cr ?hide_positions bool ~if_false_then_print_s:msg in
  let check_reflexive x =
    let compare_x_x = M.compare x x in
    check
      (compare_x_x = 0)
      [%lazy_message "[compare] is not reflexive" (x : M.t) (compare_x_x : int)]
  in
  let check_asymmetric x y =
    let compare_x_y = M.compare x y in
    let compare_y_x = M.compare y x in
    check
      (Sign.equal (Sign.of_int compare_x_y) (Sign.flip (Sign.of_int compare_y_x)))
      [%lazy_message
        "[compare] is not asymmetric"
          (x : M.t)
          (y : M.t)
          (compare_x_y : int)
          (compare_y_x : int)]
  in
  let check_transitive x y z =
    let compare_x_y = M.compare x y in
    let compare_y_z = M.compare y z in
    let compare_x_z = M.compare x z in
    let expected : Ordering.t option =
      match Ordering.of_int compare_x_y, Ordering.of_int compare_y_z with
      | Equal, Equal -> Some Equal
      | Less, Less | Less, Equal | Equal, Less -> Some Less
      | Greater, Greater | Greater, Equal | Equal, Greater -> Some Greater
      | Less, Greater | Greater, Less -> None
    in
    Option.iter expected ~f:(fun expected ->
      check
        (Ordering.equal expected (Ordering.of_int compare_x_z))
        [%lazy_message
          "[compare] is not transitive"
            (x : M.t)
            (y : M.t)
            (z : M.t)
            (compare_x_y : int)
            (compare_y_z : int)
            (compare_x_z : int)])
  in
  let test m ~f = quickcheck_m here ?config ?cr ?hide_positions m ~f in
  test
    (module M)
    ~f:(fun x ->
      check_reflexive x;
      check_asymmetric x x;
      check_transitive x x x);
  test
    (module Tuple2 (M))
    ~f:(fun (x, y) ->
      check_asymmetric x y;
      check_transitive x x y;
      check_transitive x y x;
      check_transitive y x x);
  test
    (module Tuple3 (M))
    ~f:(fun (x, y, z) ->
      check_transitive x y z;
      check_transitive x z y;
      check_transitive y x z)
;;

let test_equal here ?config ?cr ?hide_positions (module M : With_quickcheck_and_equal) =
  let check bool msg = require here ?cr ?hide_positions bool ~if_false_then_print_s:msg in
  let check_reflexive x =
    let equal_x_x = M.equal x x in
    check
      equal_x_x
      [%lazy_message "[equal] is not reflexive" (x : M.t) (equal_x_x : bool)]
  in
  let check_symmetric x y =
    let equal_x_y = M.equal x y in
    let equal_y_x = M.equal y x in
    check
      (Bool.equal equal_x_y equal_y_x)
      [%lazy_message
        "[equal] is not symmetric"
          (x : M.t)
          (y : M.t)
          (equal_x_y : bool)
          (equal_y_x : bool)]
  in
  let check_transitive x y z =
    let equal_x_y = M.equal x y in
    let equal_y_z = M.equal y z in
    let equal_x_z = M.equal x z in
    let msg =
      [%lazy_message
        "[equal] is not transitive"
          (x : M.t)
          (y : M.t)
          (z : M.t)
          (equal_x_y : bool)
          (equal_y_z : bool)
          (equal_x_z : bool)]
    in
    match equal_x_y, equal_y_z with
    | true, true -> check equal_x_z msg
    | true, false | false, true -> check (not equal_x_z) msg
    | false, false -> ()
  in
  let test m ~f = quickcheck_m here ?config ?cr ?hide_positions m ~f in
  test
    (module M)
    ~f:(fun x ->
      check_reflexive x;
      check_symmetric x x;
      check_transitive x x x);
  test
    (module Tuple2 (M))
    ~f:(fun (x, y) ->
      check_symmetric x y;
      check_transitive x x y;
      check_transitive x y x;
      check_transitive y x x);
  test
    (module Tuple3 (M))
    ~f:(fun (x, y, z) ->
      check_transitive x y z;
      check_transitive x z y;
      check_transitive y x z)
;;

let test_compare_and_equal
  here
  ?config
  ?cr
  ?hide_positions
  (module M : With_quickcheck_and_compare_and_equal)
  =
  test_compare here ?config ?cr ?hide_positions (module M);
  test_equal here ?config ?cr ?hide_positions (module M);
  let check_agreement x y =
    let compare_x_y = M.compare x y in
    let equal_x_y = M.equal x y in
    require
      here
      ?cr
      ?hide_positions
      (Bool.equal equal_x_y (compare_x_y = 0))
      ~if_false_then_print_s:
        [%lazy_message
          "[compare] and [equal] do not agree"
            (x : M.t)
            (y : M.t)
            (compare_x_y : int)
            (equal_x_y : bool)]
  in
  quickcheck_m
    here
    ?config
    ?cr
    ?hide_positions
    (module Tuple2 (M))
    ~f:(fun (x, y) ->
      check_agreement x y;
      check_agreement y x)
;;
