(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

module type S = sig
  (** Manipulating the output of processes run by vcs and backends - typically
      the ["git"] and ["hg"] commands. *)

  module Output : sig
    type t =
      { exit_code : int
      ; stdout : string
      ; stderr : string
      }

    val sexp_of_t : t -> Sexp.t

    module Private : sig
      val of_process_output : Process_output.t -> t
    end
  end

  (** This is the interface commonly used by raising and non-raising helper
      modules, such as {!module:Vcs.Git}, [Volgo_base.Vcs.Git.Or_error],
      {!module:Vcs.Git.Result}, {!module:Vcs.Git.Rresult}, and custom ones built
      with {!module:Vcs.Git.Non_raising.Make}. [S] is parametrized by the result
      type returned by the helpers. *)
  module type S = Process_intf.S with type process_output := Output.t

  (** The interface exposed at the top level of this module are helpers that
      return direct results, or raise [Err.E]. This module is exported to users
      as [Vcs.Git].

      The helpers are suitable for use in combination with the {!val:Vcs.git}
      function, which will take care of wrapping the exception with useful
      context, before re-raising it. *)
  include S with type 'a result := 'a

  module Non_raising : sig
    (** A functor to build non raising helpers based on a custom error type.

        In addition to {!module:Vcs.Git.Result}, {!module:Vcs.Git.Rresult} and
        [Volgo_base.Vcs.Git.Or_error], we provide this functor to create a [Git.S]
        interface based on a custom error type of your choice. *)

    module type M = Error_intf.S

    module Make (M : M) : S with type 'a result := ('a, M.t) Result.t
  end

  module Rresult : S with type 'a result := ('a, Vcs_rresult0.t) Result.t
  module Result : S with type 'a result := ('a, Err.t) Result.t
end
