# vcs

[![CI Status](https://github.com/mbarbin/vcs/workflows/ci/badge.svg)](https://github.com/mbarbin/vcs/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/mbarbin/vcs/badge.svg?branch=main)](https://coveralls.io/github/mbarbin/vcs?branch=main)

A versatile OCaml library for Git interaction

## Overview

`Vcs` is an OCaml library providing a direct-style API for interacting with Git
repositories. It's designed as an "interface", or "virtual" library with the
actual implementation dynamically dispatched at runtime. This design allows for
high flexibility and adaptability to different use cases.

## Architecture

The `vcs` repository contains several components:

![Git-cli diagram](doc/diagram/gitcli.png)

- **vcs**: The main entry point of the library. Marked with a * to indicate no
  runtime dependencies.
- **user-lib**: A placeholder in the diagram for any library that uses `Vcs`.
  Also marked with a * to indicate no runtime dependencies.
- **executable**: A placeholder for a runtime component based on `user-lib` that
  commits to a specific provider and concurrency model.
- **git-cli**: A IO-free library that parses the output of a `git` cli process.
- **vcs-git**: An instantiation of `Git_cli` based on an `Eio` runtime.
- **vcs-git-blocking**: An instantiation of `Git_cli` based on the OCaml `Stdlib`.

![Stdlib diagram](doc/diagram/stdlib.png)

## Design principles

`Vcs` is designed to be backend-agnostic and concurrency-runtime independent.
It's compatible with both `Eio` and OCaml `Stdlib` runtimes. We plan to explore
the feasibility of supporting [luv](https://github.com/aantron/luv) and
[miou](https://github.com/robur-coop/miou) runtimes as separate future work.

The concurrency runtime must be compatible with program written in direct style.
Runtime based on monadic concurrent models such as `Async` and `Lwt` are
purposely left outside of the scope of this project.

## How It Works

`Vcs` is an interface composed of [Traits](doc/traits.md), each providing
different functionalities associated with Git interaction. The dynamic dispatch
implementation uses the [provider](https://github.com/mbarbin/provider) library.

## Motivation

We aim to create a highly compatible library that can serve various use cases
and foster community engagement. We also hope to gain practical experience with
the use of provider-based parametric libraries.

## Relation to ocaml-git

[ocaml-git](https://github.com/mirage/ocaml-git) is a pure OCaml implementation
of the Git format and protocol. In the `Vcs` framework, an Eio compatible
`ocaml-git` is a potential `provider` for the interface. We plan to create a
`Vcs` provider based on `ocaml-git` in the future.

![Ocaml-git diagram](doc/diagram/ocaml-git.png)

## Acknowledgements

We would like to express our gratitude to the `Eio` developers for their work on
the [Eio](https://github.com/ocaml-multicore/eio) project. The development of
`Eio` has sparked a great deal of enthusiasm for us in our work on the `Vcs`
project.

We would like to express our appreciation for the work done by the Jane Street
developers and their significant contributions to the open source community. In
particular, this project has drawn inspiration from the `Mercurial` backend of
`Iron`, Jane Street's code review tool. For more details about how `Iron` has
influenced this project and the licensing implications, please refer to the
`NOTICE.md` file.

We would like to thank Vincent Simonet and contributors for
[headache](https://github.com/Frama-C/headache), which we use to manage the
copyright headers at the beginning of our files.

## Current Status

The project is currently in the draft stage in a private repository. We're in
the process of seeking preliminary feedback, and gradually writing and
publishing the code.
