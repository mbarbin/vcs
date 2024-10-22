# Vcs_base

In this file we document a multi-stages refactoring that is currently in progress in the repository.

## Targeted end result

The aim of this refactoring is to remove the base dependency of the `Vcs` library. To achieve this, we will offer two distinct libraries:

- `Vcs` - a kernel library that can be used with very little dependencies;
- `Vcs_base` - an extension of `Vcs` which will add some functionality related to working with `Base`.

## Stages

### Stage 1 - Introducing `Vcs_base`

- [x] Completed: Oct. 2024

In this stage, we create the library `Vcs_base` and setup the way in which this library extends `Vcs`. It exposes the same modules, plus extra functionality, such as:

- Base style `hash` signatures
- `Comparable.S` signatures for use with Base style containers
- Make some functions return sets instead of lists.

### Stage 2 - Reducing ppx dependencies in `Vcs`

- [x] Completed: Oct. 2024

Only keep sexp related ppx that have no runtime dependency on `base`, such as `sexplib0` only.

- Remove `ppx_compare`, `ppx_here`, `ppx_let` dependencies.

### Stage 3 - Refactor non-raising APIs

- [x] Completed: Oct. 2024

- Rename `Result` => `Rresult`, introduce a new `Result` one.

### Stage 4 - Trait implementation use `Result`

- [x] Completed: Oct. 2024

### Stage 5 - Move modules related to `Or_error` into `Vcs_base`.

- [x] Completed: Oct. 2024

### Stage 6 - Remove base dependency from `Vcs`

- [ ] Pending

Use `vcs/src/import` to make a local mini-stdlib with utils required to remove `base` dependency.

Do this for the other libraries:

- [ ] vcs
- [ ] vcs_command
- [ ] vcs_git_blocking
- [ ] vcs_git_eio
- [ ] vcs_git_provider
