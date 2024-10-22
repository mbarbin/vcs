## 0.0.9 (unreleased)

### Added

- Add new `vcs-base` package meant to extend `vcs` with base-style functionality (#31, @mbarbin).
- Add `Vcs.find_enclosing_repo_root` helper (#28, @mbarbin).
- Add `Vcs.read_dir` helper (#28, @mbarbin).

### Changed

- Provider interfaces now uses `Vcs.Result` type instead of `Or_error` (#34, @mbarbin).
- Rename what was `Vcs.Result` to `Vcs.Rresult` and introduce `Vcs.Result` whose type is simpler (#33, @mbarbin).
- Moved `ocaml-vcs more-tests` commands at top-level (#28, @mbarbin).

### Deprecated

### Fixed

- Changed some exceptions raised by the `vcs` related libraries to the `Vcs.E` exception (#34, @mbarbin).

### Removed

- Removed `Vcs.Exn.raise_s` since it is causing `bisect_ppx` unvisitable points (#34, @mbarbin).
- Removed package `vcs-arg` and inline what's needed directly in `vcs-command` (#28, @mbarbin).

## 0.0.8 (2024-09-30)

### Changed

- Reduced dependencies from `fpath-base` to `fpath-sexp0` where able (#27, @mbarbin).
- Inline `eio-process` dependency into `vcs_git_eio` (#27, @mbarbin).
- Replace calls to `eio-writer` by print functions from stdlib in `vcs-command` (#26, @mbarbin).
- Refactor subgraph computation to not need union-find (#25, @mbarbin).
- Improve `Vcs.Graph` documentation (#24, @mbarbin).
- Upgrade documentation dependencies (#23, @mbarbin).
- Update documentation to use diataxis (#22, @mbarbin).

### Fixed

- Fixed stale names in headache script.

### Removed

- No more `vendor/` libraries.
- Removed dependency to vendored `eio-process`.
- Removed dependency to vendored `eio-writer`.
- Removed dependency to vendored `union-find`.

## 0.0.7 (2024-09-20)

### Changed

- Rename `vcs-git-cli` to `vcs-git-provider` (breaking change).
- Rename `vcs-git` to `vcs-git-eio` (breaking change).
- Rename `tree` to `graph` to designate the commit graph of a repository (breaking change).
- Upgrade to `cmdlang.0.0.5`.

### Fixed

- Retrieve some code coverage lost during the last release.

## 0.0.6 (2024-09-07)

### Changed

- Upgrade to `cmdlang.0.0.4`.
- Use type `Msg of string` for `of_string` errors.
- Now using `expect_test_helpers_base`.
- Upgrade to `err0` and more recent `cmdlang`.

### Removed

- Removed vendored `expect-test-helpers`.

## 0.0.5 (2024-08-19)

### Changed

- Renamed `vcs_param` to `vcs_arg` to match cmdlang conventions.
- Switch commands to new library `cmdlang` with `cmdliner` backend.
- Upgrade `provider` to `0.0.8`.

## 0.0.4 (2024-08-05)

Release a version compatible with the latest renames in the provider library.

### Changed

- Upgrade `provider` to `0.0.7`.

## 0.0.3 (2024-07-28)

### Added

- Expose gca function in the `ocaml-vcs` command line.
- Add function and tests to compute GCAs in `Vcs.Graph`.

### Changed

- Rename `Vcs.Descendance.t` constructors for clarity.
- Improve `Vcs.Graph.Node` interface.
- Improve `Vcs.Graph.sexp_of_t` to help with debugging.
- Rename `git_cli` library to `vcs_git_cli` for consistency.
- Remove type parameter for `Vcs.Graph.Node_kind` (simplify interface).
- Renamed constructors for root nodes in vcs graphs (`Init` => `Root`).

### Fixed

- Fix `Vcs.Graph.add_nodes` raising when adding nodes incrementally.

## 0.0.2 (2024-07-26)

### Added

- Add documentation website powered by Docusaurus. (#7, @mbarbin)
- Initiate a library `vcs-test-helpers` to help writing tests. (#4, @mbarbin)
- Add test showing how to do revision lookup from references using `Vcs.refs` and `Vcs.graph`.
- Added dependabot config for automatically upgrading action files.

### Changed

- Upgrade `ppxlib` to `0.33` - activate unused items warnings.
- Refactor `Vcs.Git` to clarify raising/non-raising APIs (breaking change). (#9, @mbarbin)
- Upgrade `ocaml` to `5.2`.
- Upgrade `dune` to `3.16`.
- Upgrade base & co to `0.17`.

### Fixed

- Fix computation of `repo_root` when inside a git worktree.
- Handle binary files in `Vcs.num_status` instead of failing.
- Allow more characters when parsing branch names.

### Removed

- Removed `Vcs.rev_parse`, replaced by other dedicated function `Vcs.current_{branch,revision}`. (#3, @mbarbin)

## 0.0.1 (2024-03-19)

### Added

- Exposes 1 raising and 2 non-raising APIs. Improve error handling.
- Add license and notices.
- Add libraries skeletons with their opam files.

### Changed

- Vendor `expect-test-helpers`.
- Upgrade `fpath-base` to `0.0.9` (was renamed from `fpath-extended`).
- Upgrade `eio` to `1.0` (no change required).
- Uses `expect-test-helpers` (reduce core dependencies)
- Upgrade `eio` to `0.15`.
- Run `ppx_js_style` as a linter & make it a `dev` dependency.
- Upgrade GitHub workflows `actions/checkout` to v4.
- In CI, specify build target `@all`, and add `@lint`.
- List ppxs instead of `ppx_jane`.
