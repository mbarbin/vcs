## 0.0.2 (unreleased)

### Added

- Initiate a library `vcs-test-helpers` to help writing tests.
- Add test showing how to do revision lookup from references using `Vcs.refs` and `Vcs.tree`.

### Changed

- Upgrade `ocaml` to `5.2`.
- Upgrade `dune` to `3.16`.

### Deprecated

### Fixed

- Fix computation of `repo_root` when inside a git worktree.
- Handle binary files in `Vcs.num_status` instead of failing.
- Allow more characters when parsing branch names.

### Removed

- Removed `Vcs.rev_parse`, replaced by other dedicated function `Vcs.current_{branch,revision}`.

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
