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

;; The value for the [implicit_transitive_deps] option is set during the CI
;; depending on the OCaml compiler version.
;;
;; This will be set to [false] iif [ocaml-version >= 5.2].
;;
;; For packaging purposes with older ocaml, it is simpler atm if the option is
;; set to [true] in the main branch.
;;
;; See: [.github/workflows/edit_dune_project_dot_ml].

(implicit_transitive_deps true)

(package
 (name volgo)
 (synopsis "A Versatile OCaml Library for Git Operations")
 (depends
  (ocaml
   (>= 4.14))
  (bitv
   (>= 2.1))
  (dyn
   (>= 3.17))
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.4.0))
  (ordering
   (>= 3.17))
  (pp
   (>= 2.0.0))
  (pplumbing-err
   (>= 0.0.16))
  (pplumbing-pp-tty
   (>= 0.0.16))
  (sexplib0
   (>= v0.16))))

(package
 (name volgo-base)
 (synopsis "An Extension of volgo.Vcs to use with Base")
 (depends
  (ocaml
   (>= 5.2))
  (base
   (>= v0.17))
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.4.0))
  (pp
   (>= 2.0.0))
  (pplumbing-err
   (>= 0.0.16))
  (pplumbing-pp-tty
   (>= 0.0.16))
  (ppx_hash
   (>= v0.17))
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
  (cmdlang-cmdliner-err-runner
   (>= 0.0.16))
  (conf-git :with-test)
  (conf-hg :with-test)
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.4.0))
  (pp
   (>= 2.0.0))
  (pplumbing-err
   (>= 0.0.16))
  (pplumbing-pp-tty
   (>= 0.0.16))
  (sexplib0
   (>= v0.16))
  (volgo
   (= :version))
  (volgo-git-backend
   (= :version))
  (volgo-git-unix
   (= :version))
  (volgo-hg-backend
   (= :version))
  (volgo-hg-unix
   (= :version))
  (yojson
   (>= 2.1.1))))

(package
 (name volgo-git-backend)
 (synopsis "An IO-free library that parses the output of Git commands")
 (depends
  (ocaml
   (>= 4.14))
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.4.0))
  (pp
   (>= 2.0.0))
  (pplumbing-err
   (>= 0.0.16))
  (pplumbing-pp-tty
   (>= 0.0.16))
  (sexplib0
   (>= v0.16))
  (volgo
   (= :version))))

(package
 (name volgo-hg-backend)
 (synopsis "An IO-free library that parses the output of Mercurial commands")
 (depends
  (ocaml
   (>= 4.14))
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.4.0))
  (pp
   (>= 2.0.0))
  (pplumbing-err
   (>= 0.0.16))
  (pplumbing-pp-tty
   (>= 0.0.16))
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
  (conf-git :with-test)
  (eio
   (>= 1.0))
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.4.0))
  (pp
   (>= 2.0.0))
  (pplumbing-err
   (>= 0.0.16))
  (pplumbing-pp-tty
   (>= 0.0.16))
  (sexplib0
   (>= v0.17))
  (volgo
   (= :version))
  (volgo-git-backend
   (= :version))))

(package
 (name volgo-hg-eio)
 (synopsis
  "A Mercurial backend for Vcs based on Volgo_hg_backend for Eio programs")
 (depends
  (ocaml
   (>= 5.2))
  (conf-hg :with-test)
  (eio
   (>= 1.0))
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.4.0))
  (pp
   (>= 2.0.0))
  (pplumbing-err
   (>= 0.0.16))
  (pplumbing-pp-tty
   (>= 0.0.16))
  (sexplib0
   (>= v0.17))
  (volgo
   (= :version))
  (volgo-git-eio
   (= :version))
  (volgo-hg-backend
   (= :version))))

(package
 (name volgo-git-unix)
 (synopsis
  "A Git backend for Vcs based on Volgo_git_backend and the Unix library")
 (depends
  (ocaml
   (>= 4.14))
  (conf-git :with-test)
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.4.0))
  (pp
   (>= 2.0.0))
  (pplumbing-err
   (>= 0.0.16))
  (pplumbing-pp-tty
   (>= 0.0.16))
  (sexplib0
   (>= v0.16))
  (spawn
   (>= v0.16))
  (volgo
   (= :version))
  (volgo-git-backend
   (= :version))))

(package
 (name volgo-hg-unix)
 (synopsis
  "A Mercurial backend for Vcs based on Volgo_hg_backend and the Unix library")
 (depends
  (ocaml
   (>= 4.14))
  (conf-hg :with-test)
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.4.0))
  (pp
   (>= 2.0.0))
  (pplumbing-err
   (>= 0.0.16))
  (pplumbing-pp-tty
   (>= 0.0.16))
  (sexplib0
   (>= v0.16))
  (volgo
   (= :version))
  (volgo-git-unix
   (= :version))
  (volgo-hg-backend
   (= :version))))

(package
 (name vcs-test-helpers)
 (synopsis "Helper library to write tests using vcs")
 (depends
  (ocaml
   (>= 5.2))
  (eio
   (>= 1.0))
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.4.0))
  (pp
   (>= 2.0.0))
  (pplumbing-err
   (>= 0.0.16))
  (pplumbing-pp-tty
   (>= 0.0.16))
  (volgo
   (= :version))))

(package
 (name volgo-tests)
 (synopsis "Tests & Examples for volgo")
 (depends
  (ocaml
   (and
    (>= 5.2)
    (< 5.4~)))
  (bitv
   (>= 2.1))
  (cmdlang
   (>= 0.0.9))
  (cmdlang-cmdliner-err-runner
   (>= 0.0.16))
  (cmdliner
   (and
    (>= 1.3.0)
    (< 2.0)))
  conf-git
  conf-hg
  (eio
   (>= 1.0))
  (eio_main
   (>= 1.0))
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.4.0))
  (pp
   (>= 2.0.0))
  (pplumbing-err
   (>= 0.0.16))
  (pplumbing-pp-tty
   (>= 0.0.16))
  (ppx_expect
   (>= v0.17))
  (ppxlib
   (>= 0.33))
  (re
   (>= 1.8.0))
  (spawn
   (>= v0.17))
  (vcs-test-helpers
   (= :version))
  (volgo
   (= :version))
  (volgo-git-backend
   (= :version))
  (volgo-git-eio
   (= :version))
  (volgo-git-unix
   (= :version))
  (volgo-hg-backend
   (= :version))
  (volgo-hg-eio
   (= :version))
  (volgo-hg-unix
   (= :version))
  (volgo-vcs
   (= :version))))

(package
 (name volgo-base-tests)
 (synopsis "Tests for volgo-base")
 (depends
  (ocaml
   (>= 5.2))
  (base
   (>= v0.17))
  conf-git
  (eio
   (>= 1.0))
  (eio_main
   (>= 1.0))
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.4.0))
  (pp
   (>= 2.0.0))
  (pplumbing-err
   (>= 0.0.16))
  (ppx_expect
   (>= v0.17))
  (ppx_hash
   (>= v0.17))
  (ppxlib
   (>= 0.33))
  (volgo
   (= :version))
  (volgo-base
   (= :version))
  (volgo-git-backend
   (= :version))))

(package
 (name volgo-dev)
 (synopsis "Package to regroup dev targets, documentation, and more")
 (allow_empty)
 (depends
  (ocaml
   (and
    (>= 5.3)
    (< 5.4~)))
  (ocamlformat
   (= 0.28.1))
  (bisect_ppx
   (>= 2.8.3))
  (cmdliner
   (and
    (>= 1.3.0)
    (< 2.0)))
  conf-git
  conf-hg
  (mdx
   (>= 2.4))
  (ppx_js_style
   (>= v0.17))
  (ppxlib
   (>= 0.33))
  (vcs-test-helpers
   (= :version))
  (volgo
   (= :version))
  (volgo-base
   (= :version))
  (volgo-base-tests
   (= :version))
  (volgo-git-backend
   (= :version))
  (volgo-git-eio
   (= :version))
  (volgo-git-unix
   (= :version))
  (volgo-hg-backend
   (= :version))
  (volgo-hg-eio
   (= :version))
  (volgo-hg-unix
   (= :version))
  (volgo-tests
   (= :version))
  (volgo-vcs
   (= :version))
  (sherlodoc
   (>= 0.2))))
