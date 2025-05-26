(lang dune 3.17)

(name volgo)

(generate_opam_files)

(license "LGPL-3.0-or-later WITH LGPL-3.0-linking-exception")

(authors "Mathieu Barbin")

(maintainers "Mathieu Barbin <opensource@mbarbin.org>")

(source
 (github mbarbin/vcs))

(documentation "https://mbarbin.github.io/vcs/")

(using mdx 0.4)

(implicit_transitive_deps false)

(package
 (name volgo)
 (synopsis "A Versatile OCaml Library for Git Operations")
 (depends
  (ocaml
   (>= 4.14))
  (astring
   (>= 0.8.5))
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.2.2))
  (pp
   (>= 2.0.0))
  (pplumbing
   (>= 0.0.13))
  (ppx_enumerate
   (>= v0.16))
  (ppx_sexp_conv
   (>= v0.16))
  (ppx_sexp_value
   (>= v0.16))
  (ppxlib
   (>= 0.33))))

(package
 (name volgo-base)
 (synopsis "An Extension of volgo.Vcs to use with Base")
 (depends
  (ocaml
   (>= 5.2))
  (base
   (and
    (>= v0.17)
    (< v0.18)))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.2.2))
  (pp
   (>= 2.0.0))
  (pplumbing
   (>= 0.0.13))
  (ppx_compare
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_enumerate
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_hash
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_here
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_let
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_conv
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_value
   (and
    (>= v0.17)
    (< v0.18)))
  (ppxlib
   (>= 0.33))
  (volgo
   (= :version))))

(package
 (name volgo-vcs)
 (synopsis
  "A command line tool for vcs operations based on the volgo libraries")
 (depends
  (ocaml
   (>= 4.14))
  (cmdlang
   (>= 0.0.9))
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.2.2))
  (pp
   (>= 2.0.0))
  (pplumbing
   (>= 0.0.13))
  (ppx_sexp_value
   (>= v0.16))
  (ppxlib
   (>= 0.33))
  (sexplib0
   (>= v0.16))
  (volgo
   (= :version))
  (volgo-git-backend
   (= :version))
  (volgo-git-unix
   (= :version))))

(package
 (name volgo-git-backend)
 (synopsis "An IO-free library that parses the output of Git commands")
 (depends
  (ocaml
   (>= 4.14))
  (astring
   (>= 0.8.5))
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.2.2))
  (pp
   (>= 2.0.0))
  (pplumbing
   (>= 0.0.13))
  (ppx_sexp_conv
   (>= v0.16))
  (ppx_sexp_value
   (>= v0.16))
  (ppxlib
   (>= 0.33))
  (sexplib0
   (>= v0.16))
  (volgo
   (= :version))))

(package
 (name volgo-git-eio)
 (synopsis
  "A Git backend for Vcs based on Volgo_git_backend for Eio programs")
 (depends
  (ocaml
   (>= 5.2))
  (eio
   (>= 1.0))
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.2.2))
  (pp
   (>= 2.0.0))
  (pplumbing
   (>= 0.0.13))
  (ppx_sexp_conv
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_value
   (and
    (>= v0.17)
    (< v0.18)))
  (ppxlib
   (>= 0.33))
  (sexplib0
   (and
    (>= v0.17)
    (< v0.18)))
  (volgo
   (= :version))
  (volgo-git-backend
   (= :version))))

(package
 (name volgo-git-unix)
 (synopsis
  "A Git backend for Vcs based on Volgo_git_backend and the Unix library")
 (depends
  (ocaml
   (>= 4.14))
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.2.2))
  (pp
   (>= 2.0.0))
  (pplumbing
   (>= 0.0.13))
  (ppx_sexp_conv
   (>= v0.16))
  (ppx_sexp_value
   (>= v0.16))
  (ppxlib
   (>= 0.33))
  (sexplib0
   (>= v0.16))
  (shexp
   (>= v0.16))
  (volgo
   (= :version))
  (volgo-git-backend
   (= :version))))

(package
 (name vcs-test-helpers)
 (synopsis "Helper library to write tests using vcs")
 (depends
  (ocaml
   (>= 5.2))
  (base
   (and
    (>= v0.17)
    (< v0.18)))
  (eio
   (>= 1.0))
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.2.2))
  (pp
   (>= 2.0.0))
  (pplumbing
   (>= 0.0.13))
  (ppx_compare
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_enumerate
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_hash
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_here
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_let
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_conv
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_value
   (and
    (>= v0.17)
    (< v0.18)))
  (ppxlib
   (>= 0.33))
  (volgo
   (= :version))))

(package
 (name volgo-tests)
 (synopsis "Tests & Examples for volgo")
 (depends
  (ocaml
   (>= 5.2))
  (ocamlformat
   (and
    :with-dev-setup
    (= 0.27.0)))
  (astring
   (>= 0.8.5))
  (base
   (and
    (>= v0.17)
    (< v0.18)))
  (base_quickcheck
   (and
    (>= v0.17)
    (< v0.18)))
  (bisect_ppx
   (and
    :with-dev-setup
    (>= 2.8.3)))
  (cmdlang
   (>= 0.0.9))
  (core
   (and
    (>= v0.17)
    (< v0.18)))
  (eio
   (>= 1.0))
  (eio_main
   (>= 1.0))
  (expect_test_helpers_core
   (and
    (>= v0.17)
    (< v0.18)))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.2.2))
  (fpath-sexp0
   (>= 0.2.2))
  (mdx
   (and
    :with-doc
    (>= 2.4)))
  (pp
   (>= 2.0.0))
  (pplumbing
   (>= 0.0.13))
  (ppx_compare
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_enumerate
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_expect
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_hash
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_here
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_js_style
   (and
    :with-dev-setup
    (>= v0.17)
    (< v0.18)))
  (ppx_let
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_conv
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_message
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_value
   (and
    (>= v0.17)
    (< v0.18)))
  (ppxlib
   (>= 0.33))
  (re
   (>= 1.8.0))
  (sexp_pretty
   (and
    (>= v0.17)
    (< v0.18)))
  (shexp
   (and
    (>= v0.17)
    (< v0.18)))
  (stdio
   (and
    (>= v0.17)
    (< v0.18)))
  (vcs-test-helpers
   (= :version))
  (volgo
   (= :version))
  (volgo-base
   (= :version))
  (volgo-git-backend
   (= :version))
  (volgo-git-eio
   (= :version))
  (volgo-git-unix
   (= :version))
  (volgo-vcs
   (= :version))
  (sherlodoc
   (and
    :with-doc
    (>= 0.2)))))

(package
 (name volgo-dev)
 (synopsis
  "Package to regroup dev targets for the volgo project, documentation, and more")
 (allow_empty) ; The package is attached to stanza in doc/ however dune doesn't see it.
 (depends
  (ocaml
   (>= 5.2))
  (ocamlformat
   (and
    :with-dev-setup
    (= 0.27.0)))
  (astring
   (>= 0.8.5))
  (base
   (and
    (>= v0.17)
    (< v0.18)))
  (base_quickcheck
   (and
    (>= v0.17)
    (< v0.18)))
  (bisect_ppx
   (and
    :with-dev-setup
    (>= 2.8.3)))
  (cmdlang
   (>= 0.0.9))
  (core
   (and
    (>= v0.17)
    (< v0.18)))
  (eio
   (>= 1.0))
  (eio_main
   (>= 1.0))
  (expect_test_helpers_core
   (and
    (>= v0.17)
    (< v0.18)))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.2.2))
  (fpath-sexp0
   (>= 0.2.2))
  (mdx
   (>= 2.4))
  (pp
   (>= 2.0.0))
  (pplumbing
   (>= 0.0.13))
  (ppx_compare
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_enumerate
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_expect
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_hash
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_here
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_js_style
   (and
    :with-dev-setup
    (>= v0.17)
    (< v0.18)))
  (ppx_let
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_conv
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_message
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_value
   (and
    (>= v0.17)
    (< v0.18)))
  (ppxlib
   (>= 0.33))
  (re
   (>= 1.8.0))
  (sexp_pretty
   (and
    (>= v0.17)
    (< v0.18)))
  (shexp
   (and
    (>= v0.17)
    (< v0.18)))
  (stdio
   (and
    (>= v0.17)
    (< v0.18)))
  (vcs-test-helpers
   (= :version))
  (volgo
   (= :version))
  (volgo-base
   (= :version))
  (volgo-git-backend
   (= :version))
  (volgo-git-eio
   (= :version))
  (volgo-git-unix
   (= :version))
  (volgo-tests
   (= :version))
  (volgo-vcs
   (= :version))
  (sherlodoc
   (and
    :with-doc
    (>= 0.2)))))
