## 0.0.5 (2024-08-19)

### Changed

- Renamed `vcs_param` to `vcs_arg` to match commandlang conventions.
- Switch commands to new library `commandlang` with `cmdliner` backend.
- Upgrade `provider` to `0.0.8`.

## 0.0.4 (2024-08-05)

Release a version compatible with the latest renames in the provider library.

### Changed

- Upgrade `provider` to `0.0.7`.

## 0.0.3 (2024-07-28)

### Added

- Expose gca function in the `ocaml-vcs` command line.
- Add function and tests to compute GCAs in `Vcs.Tree`.

### Changed

- Rename `Vcs.Descendance.t` constructors for clarity.
- Improve `Vcs.Tree.Node` interface.
- Improve `Vcs.Tree.sexp_of_t` to help with debugging.
- Rename `git_cli` library to `vcs_git_cli` for consistency.
- Remove type parameter for `Vcs.Tree.Node_kind` (simplify interface).
- Renamed constructors for root nodes in vcs trees (`Init` => `Root`).

### Fixed

- Fix `Vcs.Tree.add_nodes` raising when adding nodes incrementally.

## 0.0.2 (2024-07-26)

### Added

- Add documentation website powered by Docusaurus. (#7, @mbarbin)
- Initiate a library `vcs-test-helpers` to help writing tests. (#4, @mbarbin)
- Add test showing how to do revision lookup from references using `Vcs.refs` and `Vcs.tree`.
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
