(* We use ["vcs_eio_process.cmxa"] as library name to limit the potential module
   name conflicts for projects linking with both [vcs] and [eio_process]. *)
module Eio_process = Eio_process
