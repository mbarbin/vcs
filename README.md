<h1 align="center">
  <p align="center">A Versatile OCaml Library for Git Operations</p>
  <img
    src="./doc/static/img/ocaml-vcs.png?raw=true"
    width='216'
    alt="Logo"
  />
</h1>

<p align="center">
  <a href="https://github.com/mbarbin/vcs/actions/workflows/ci.yml"><img src="https://github.com/mbarbin/vcs/workflows/ci/badge.svg" alt="CI Status"/></a>
  <a href="https://coveralls.io/github/mbarbin/vcs?branch=main"><img src="https://coveralls.io/repos/github/mbarbin/vcs/badge.svg?branch=main" alt="Coverage Status"/></a>
  <a href="https://github.com/mbarbin/vcs/actions/workflows/deploy-doc.yml"><img src="https://github.com/mbarbin/vcs/workflows/deploy-doc/badge.svg" alt="Deploy Doc Status"/></a>
  <a href="https://ocaml.ci.dev/github/mbarbin/vcs"><img src="https://img.shields.io/endpoint?url=https://ocaml.ci.dev/badge/mbarbin/vcs/main&logo=ocaml" alt="OCaml-CI Build Status"/></a>
</p>

Vcs is an OCaml library for interacting with Git repositories. It provides a type-safe and direct-style API to programmatically perform Git operations - ranging from creating commits and branches, to loading and navigating commit graphs in memory, computing diffs between revisions, and more.

Designed as an interface composed of traits, Vcs dynamically dispatches its implementation at runtime. It is currently distributed with two distinct backends: a non-blocking version built atop Eio, and a blocking variant based on OCaml's standard library. Both backends operate by executing git as an external process.

## Documentation

Vcs's documentation is published [here](https://mbarbin.github.io/vcs).

## Examples

Explore the [example](example/) directory to get a firsthand look at how Vcs works in practice.

## Motivation

Our goal is to create a versatile and highly compatible library that can cater to a wide range of use cases, while also fostering community engagement. We also hope to gain practical experience with the use of various technics to build parametric libraries.

## Naming is hard: Volgo vs Vcs?

To publish our "Versatile OCaml Library for Git Operations" (V-O-L-G-O) to opam, we're using a packaging naming scheme where `volgo` is a namespacing prefix.

However, the main module and entry point of the project is named `Vcs`. `Vcs` was also the original name for the entire project.

Oftentimes in the documentation, you'll find references to the project using the name of that main library, `Vcs`, as it is meant to be named in user code, rather than by using the opam name `volgo`.

The main reason for that naming duality is that, even though the project is designed such that the main library be referred to and used as `Vcs`, we didn't want to claim the `vcs.opam` name from the main opam-repository. Thus we have resorted to introducing the `volgo` name for packaging and publication purposes.

*volgo-vcs* is the name of a cli built with the libraries of this project. It is distributed by the opam package of the same name (`volgo-vcs`).

## Mercurial Compatibility

For information about Mercurial compatibility mode and how Vcs supports certain Git operations in Mercurial repositories, see [here](doc/docs/explanation/mercurial-compatibility.md).

## Known Issues

- Look for [open issues](https://github.com/mbarbin/vcs/issues) on GitHub.
- The camel depicted in the project logo has only one hump, whereas OCamls traditionally have two. We dare to hope that, as the project matures, our mascot will grow its second hump and fully embrace its OCaml heritage.

## Unknown Issues

- This is where you come in! If you discover any unknown issues, please open them on GitHub to let us know. Your contributions will help us improve this project!

## Acknowledgements

We extend our gratitude to the following individuals and teams, whose contributions have been great sources of inspiration for the `Vcs` project:

- The `Eio` developers for their work on the [Eio](https://github.com/ocaml-multicore/eio) project. The development of `Eio` has sparked a great deal of enthusiasm for us in our work on the `Vcs` project. We've also referred to Eio's [Exn](https://ocaml-multicore.github.io/eio/eio/Eio/Exn/index.html) module in the design of `Vcs`'s error handling.

- The Jane Street developers for their significant contributions to the open source community. In particular, this project has drawn inspiration from the `Mercurial` backend of `Iron`, Jane Street's code review tool. For more details about how `Iron` has influenced this project and the licensing implications, please refer to the `NOTICE.md` file.

- Vincent Simonet and contributors for [headache](https://github.com/Frama-C/headache), which we use to manage the copyright headers at the beginning of our files.

- The [Rresult](https://erratique.ch/software/rresult/doc/Rresult/index.html#usage) developers: Their usage design guidelines have been a reference in the design of `Vcs`'s error handling, the `Vcs.Rresult` module in particular.

We look forward to continuing to learn from and collaborate with the broader open source community.

## Build

This repository depends on unreleased packages found in a custom [opam-repository](https://github.com/mbarbin/opam-repository.git). You'll need to add this to your opam switch when building the project.

For example, if you use a local opam switch, this would look like this:

```sh
git clone https://github.com/mbarbin/vcs.git
cd vcs
opam switch create . 5.3.0 --no-install
eval $(opam env)
opam repo add mbarbin https://github.com/mbarbin/opam-repository.git
opam install . --deps-only --with-doc --with-test --with-dev-setup
```

Once this is setup, you can build with dune:

```sh
dune build @all @runtest
```

## Current Status

We're currently seeking feedback as we write and publish the code and its dependencies to the opam repository. Please do not hesitate to open issues on GitHub with general feedback, requests, or simply start a discussion.
