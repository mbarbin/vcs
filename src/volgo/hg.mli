(*_********************************************************************************)
(*_  Volgo - A Versatile OCaml Library for Git Operations                         *)
(*_  SPDX-FileCopyrightText: 2024-2026 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: LGPL-3.0-or-later WITH LGPL-3.0-linking-exception   *)
(*_********************************************************************************)

(** Manipulating the output of processes run by vcs and backends - typically
    the ["hg"] command.

    In the documentation below, we are referring to examples and functions based
    on the similar [Git] module. This is because both modules {!module:Git} and
    this one are implemented from a shared code and interface.

    They have the same interface, but the types of their output differ, for
    added type safety. *)

include Process_output_handler_intf.S
