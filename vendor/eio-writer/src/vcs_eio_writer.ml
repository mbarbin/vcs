(* We use ["vcs_eio_writer.cmxa"] as library name to limit the potential module
   name conflicts for projects linking with both [vcs] and [eio_writer]. *)
module Eio_writer = Eio_writer
