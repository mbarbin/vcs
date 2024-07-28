<h1 align="center">
  <p align="center">A Versatile OCaml Library for Git Interaction</p>
  <img
    src="./img/ocaml-vcs.png?raw=true"
    width='288'
    alt="Logo"
  />
</h1>

<p align="center">
  <a href="https://github.com/mbarbin/vcs/actions/workflows/ci.yml"><img src="https://github.com/mbarbin/vcs/workflows/ci/badge.svg" alt="CI Status"/></a>
  <a href="https://coveralls.io/github/mbarbin/vcs?branch=main"><img src="https://coveralls.io/repos/github/mbarbin/vcs/badge.svg?branch=main" alt="Coverage Status"/></a>
  <a href="https://github.com/mbarbin/vcs/actions/workflows/deploy-doc.yml"><img src="https://github.com/mbarbin/vcs/workflows/deploy-doc/badge.svg" alt="Deploy Doc Status"/></a>
</p>

Vcs is an OCaml library for interacting with Git repositories. It provides a type-safe and direct-style API to programmatically perform Git operations - ranging from creating commits and branches, to loading and navigating commit trees in memory, computing diffs between revisions, and more.

Designed as an interface composed of traits, Vcs dynamically dispatches its implementation at runtime. It is currently distributed with two distinct backends: a non-blocking version built atop Eio, and a blocking variant based on OCaml's standard library. Both backends operate by executing git as an external process.
