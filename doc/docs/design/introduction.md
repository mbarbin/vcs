# Design principles

`Vcs` is designed to be backend-agnostic and concurrency-runtime independent. It's compatible with both `Eio` and OCaml `Stdlib` runtimes. We plan to explore the feasibility of supporting [luv](https://github.com/aantron/luv) and [miou](https://github.com/robur-coop/miou) runtimes as separate future work.

The concurrency runtime must be compatible with programs written in a direct style. Runtime based on monadic concurrent models such as `Async` and `Lwt` are purposely left outside of the scope of this project.

## How It Works

`Vcs` is an interface composed of [Traits](./traits.md), each providing different functionalities associated with Git operations. The dynamic dispatch implementation of Vcs is powered by the [provider](https://github.com/mbarbin/provider) library.

## Architecture

The `vcs` repository contains several components:

```mermaid
stateDiagram-v2
  vcs : vcs *
  user : user-lib *
  vcs_git_provider : vcs-git-provider
  executable : executable (eio)
  provider : vcs-git-eio
  runtime : eio
  vcs --> user
  user --> executable
  vcs_git_provider --> provider
  runtime --> provider
  provider --> executable
```

- **vcs**: The main entry point of the library. Marked with a * to indicate no
  runtime dependencies.
- **user-lib**: A placeholder in the diagram for any library that uses `Vcs`.
  Also marked with a * to indicate no runtime dependencies.
- **executable**: A placeholder for a runtime component based on `user-lib` that
  commits to a specific provider and concurrency model.
- **vcs-git-provider**: A IO-free library that parses the output of a `git` cli process.
- **vcs-git-eio**: An instantiation of `Vcs_git_provider` based on an `Eio` runtime.
- **vcs-git-blocking**: An instantiation of `Vcs_git_provider` based on the OCaml `Stdlib`.

```mermaid
stateDiagram-v2
  vcs : vcs *
  user : user-lib *
  vcs_git_provider : vcs-git-provider
  executable : executable (blocking)
  provider : vcs-git-blocking
  runtime : stdlib
  vcs --> user
  user --> executable
  vcs_git_provider --> provider
  runtime --> provider
  provider --> executable
```

## Relation to ocaml-git

[ocaml-git](https://github.com/mirage/ocaml-git) is a pure OCaml implementation of the Git format and protocol. In the `Vcs` framework, an Eio compatible `ocaml-git` is a potential `provider` for the interface. We plan to create a `Vcs` provider based on `ocaml-git` in the future.

```mermaid
stateDiagram-v2
  vcs : vcs *
  user : user-lib *
  executable : executable (eio)
  ocaml_git : ocaml_git_eio
  provider : ocaml-git-provider
  runtime : eio
  vcs --> user
  user --> executable
  ocaml_git --> provider
  runtime --> provider
  provider --> executable
```
