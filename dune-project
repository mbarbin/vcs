(lang dune 3.14)

(name vcs)

(generate_opam_files)

(license "LGPL-3.0-or-later WITH LGPL-3.0-linking-exception")

(authors "Mathieu Barbin")

(maintainers "Mathieu Barbin")

(source
 (github mbarbin/vcs))

(documentation "https://mbarbin.github.io/vcs/")

(package
 (name vcs)
 (synopsis "A versatile OCaml library for Git interaction")
 (depends
  (ocaml
   (>= 5.1))
  (base
   (and
    (>= v0.16)
    (< v0.17)))
  (bisect_ppx
   (and
    :dev
    (>= 2.8.3)))
  (expect-test-helpers
   (and
    :with-test
    (>= v0.16)
    (< v0.17)))
  (fpath
   (>= 0.7.3))
  (fpath-extended
   (>= 0.0.7))
  (ppx_compare
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_enumerate
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_expect
   (and
    :with-test
    (>= v0.16)
    (< v0.17)))
  (ppx_hash
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_here
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_js_style
   (and
    :dev
    (>= v0.16)
    (< v0.17)))
  (ppx_let
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_sexp_conv
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_sexp_value
   (and
    (>= v0.16)
    (< v0.17)))
  (provider
   (>= 0.0.4))
  (union-find
   (and
    (>= v0.16)
    (< v0.17)))))

(package
 (name vcs-param)
 (synopsis "[Command.Param] helpers for the Vcs library")
 (depends
  (ocaml
   (>= 5.1))
  (base
   (and
    (>= v0.16)
    (< v0.17)))
  (bisect_ppx
   (and
    :dev
    (>= 2.8.3)))
  (core
   (and
    (>= v0.16)
    (< v0.17)))
  (eio
   (>= 0.15))
  (expect-test-helpers
   (and
    :with-test
    (>= v0.16)
    (< v0.17)))
  (fpath
   (>= 0.7.3))
  (fpath-extended
   (>= 0.0.7))
  (ppx_compare
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_enumerate
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_expect
   (and
    :with-test
    (>= v0.16)
    (< v0.17)))
  (ppx_hash
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_here
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_js_style
   (and
    :dev
    (>= v0.16)
    (< v0.17)))
  (ppx_let
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_sexp_conv
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_sexp_value
   (and
    (>= v0.16)
    (< v0.17)))
  (vcs
   (= :version))))

(package
 (name vcs-command)
 (synopsis "A command line tool for the Vcs library")
 (depends
  (ocaml
   (>= 5.1))
  (base
   (and
    (>= v0.16)
    (< v0.17)))
  (bisect_ppx
   (and
    :dev
    (>= 2.8.3)))
  (command-unix-for-opam
   (>= 0.0.2))
  (core
   (and
    (>= v0.16)
    (< v0.17)))
  (eio
   (>= 0.15))
  (eio-writer
   (>= 0.0.3))
  (eio_main
   (>= 0.15))
  (expect-test-helpers
   (and
    :with-test
    (>= v0.16)
    (< v0.17)))
  (fpath
   (>= 0.7.3))
  (fpath-extended
   (>= 0.0.7))
  (ppx_compare
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_enumerate
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_expect
   (and
    :with-test
    (>= v0.16)
    (< v0.17)))
  (ppx_hash
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_here
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_js_style
   (and
    :dev
    (>= v0.16)
    (< v0.17)))
  (ppx_let
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_sexp_conv
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_sexp_value
   (and
    (>= v0.16)
    (< v0.17)))
  (vcs
   (= :version))
  (vcs-param
   (= :version))))

(package
 (name git-cli)
 (synopsis "An IO-free library that parses the output of Git commands")
 (depends
  (ocaml
   (>= 5.1))
  (base
   (and
    (>= v0.16)
    (< v0.17)))
  (bisect_ppx
   (and
    :dev
    (>= 2.8.3)))
  (expect-test-helpers
   (and
    :with-test
    (>= v0.16)
    (< v0.17)))
  (fpath
   (>= 0.7.3))
  (fpath-extended
   (>= 0.0.7))
  (ppx_compare
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_enumerate
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_expect
   (and
    :with-test
    (>= v0.16)
    (< v0.17)))
  (ppx_hash
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_here
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_js_style
   (and
    :dev
    (>= v0.16)
    (< v0.17)))
  (ppx_let
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_sexp_conv
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_sexp_value
   (and
    (>= v0.16)
    (< v0.17)))
  (vcs
   (= :version))))

(package
 (name vcs-git)
 (synopsis "A Git provider for Vcs based on Git_cli for Eio programs")
 (depends
  (ocaml
   (>= 5.1))
  (base
   (and
    (>= v0.16)
    (< v0.17)))
  (bisect_ppx
   (and
    :dev
    (>= 2.8.3)))
  (eio
   (>= 0.15))
  (eio-process
   (>= 0.0.1))
  (expect-test-helpers
   (and
    :with-test
    (>= v0.16)
    (< v0.17)))
  (fpath
   (>= 0.7.3))
  (fpath-extended
   (>= 0.0.7))
  (git-cli
   (= :version))
  (ppx_compare
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_enumerate
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_expect
   (and
    :with-test
    (>= v0.16)
    (< v0.17)))
  (ppx_hash
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_here
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_js_style
   (and
    :dev
    (>= v0.16)
    (< v0.17)))
  (ppx_let
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_sexp_conv
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_sexp_value
   (and
    (>= v0.16)
    (< v0.17)))
  (provider
   (>= 0.0.4))
  (vcs
   (= :version))))

(package
 (name vcs-git-blocking)
 (synopsis "A Git provider for Vcs based on Git_cli for blocking programs")
 (depends
  (ocaml
   (>= 5.1))
  (base
   (and
    (>= v0.16)
    (< v0.17)))
  (bisect_ppx
   (and
    :dev
    (>= 2.8.3)))
  (expect-test-helpers
   (and
    :with-test
    (>= v0.16)
    (< v0.17)))
  (fpath
   (>= 0.7.3))
  (fpath-extended
   (>= 0.0.7))
  (git-cli
   (= :version))
  (ppx_compare
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_enumerate
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_expect
   (and
    :with-test
    (>= v0.16)
    (< v0.17)))
  (ppx_hash
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_here
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_js_style
   (and
    :dev
    (>= v0.16)
    (< v0.17)))
  (ppx_let
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_sexp_conv
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_sexp_value
   (and
    (>= v0.16)
    (< v0.17)))
  (provider
   (>= 0.0.4))
  (vcs
   (= :version))))
