## 0.0.18 (unreleased)

### Added

- Add `conf-git` dependency to tests using the `git` cli (#73, @mbarbin).

### Changed

- Set `prog` to the executable basename in error context for stability (#77, @mbarbin).
- Replace `shexp` by direct use of `spawn` (#76, @mbarbin).

### Deprecated

### Fixed

- Make `hg` more silent during tests for stability (#77, @mbarbin).
- Require `5.3` for `volgo-dev` for stability (#77, @mbarbin).
- Fix build with OCaml `5.0` (#73, @mbarbin).

### Removed

## 0.0.17 (2025-06-05)

### Added

- Add Mercurial Compatibility Mode & Backends (#70, #71, @mbarbin).
- Add support for OCaml-4.14 to `volgo-vcs` CLI (#68, @mbarbin).

### Changed

- Conditional set implicit transitive deps in CI depending on the compiler version (#67, @mbarbin).

### Fixed

- Fix lint-doc warnings introduced with odoc v3 (#67, @mbarbin).

## 0.0.16 (2025-05-25)

This release contains a major repackaging of the project to make it easier to publish to opam without using the short and canonical name `vcs.opam`. The project is now named `volgo` (Versatile Ocaml Library for Git Operations).

### Changed

- Repackage project with the prefix name `volgo` for publication (#66, @mbarbin).
- Rename the main cli `volgo-vcs` (#66, @mbarbin).

### Removed

- Removed deprecated APIs (#65, @mbarbin).

## 0.0.15 (2025-05-22)

### Added

- Add support for OCaml-4.14 to `vcs`, `vcs-git-backend` & `vcs-git-unix` (#64, @mbarbin).

### Changed

- Some improvements to `Graph.gcas` computation (#61, @mbarbin).

### Deprecated

- Actually mark for deprecation all the functions, modules and exceptions that were prepared to be deprecated (#64, @mbarbin).

## 0.0.14 (2025-05-07)

This release prepares the deprecation of a few functions and contains `ocamlmig` annotations to help users with the migration.

To automatically apply the migration changes, first upgrade your `vcs` dependency and re-build your project. Then run the command `ocamlmig migrate` from the root of your project.

### Added

- Add dependency to `pp` and `pplumbing.err` (#58, @mbarbin).

### Changed

- Unify `Vcs.Err` with `pplumbing.Err` (#60, @mbarbin).
- Make some tweaks to vcs errors and exceptions sexp formats (#57, @mbarbin).

### Deprecated

- Prepare for deprecation `Vcs.Err` and `Vcs.Exn` (#60, @mbarbin).

## 0.0.13 (2025-05-02)

### Changed

- Switch from Provider to OCaml Objects based design (#56, @mbarbin).

## 0.0.12 (2025-05-01)

### Added

- Add `ocaml-vcs` subcommand to compute descendance relation between 2 nodes (#55, @mbarbin).

### Changed

- Rename `vcs-git-blocking` to `vcs-git-unix` (#54, @mbarbin).
- Switch the backend used in `vcs-cli` from `eio` to `blocking` (#53, @mbarbin).
- Pre-locate the git executable in `vcs_git_blocking` (#52, @mbarbin).

### Fixed

- Dispose of `Shexp_process.Context` in `vcs_git_blocking` (#52, @mbarbin).

## 0.0.11 (2025-04-13)

### Changed

- Use dependencies from `pplumbing` (#51, @mbarbin).
- Rename `_command` to `_cli` in files and packages (e.g. `vcs-cli`) (#50, @mbarbin).

### Fixed

- Allow `vcs-git-unix` calls to be run in parallel (#49, @mbarbin).

## 0.0.10 (2024-11-05)

### Changed

- Upgrade to `provider.0.0.11` with breaking changes (#43, @mbarbin).
- Abstract the trait type constructors (#42, @mbarbin).

## 0.0.9 (2024-10-23)

### Added

- Add new `vcs-base` package meant to extend `vcs` with base-style functionality (#31, @mbarbin).
- Add `Vcs.find_enclosing_repo_root` helper (#28, @mbarbin).
- Add `Vcs.read_dir` helper (#28, @mbarbin).

### Changed

- Added more labels to the `Vcs.Graph` signature (#38, @mbarbin).
- Rename `tips` to `leaves` to designate nodes without children (#38, @mbarbin).
- Remove `base` dependency from `vcs` and provider libraries (#36, @mbarbin).
- Moved `Or_error` related modules to `Vcs_base` (#35, @mbarbin).
- Provider interfaces now uses `Vcs.Result` type instead of `Or_error` (#34, @mbarbin).
- Rename what was `Vcs.Result` to `Vcs.Rresult` and introduce `Vcs.Result` whose type is simpler (#33, @mbarbin).
- Moved `ocaml-vcs more-tests` commands at top-level (#28, @mbarbin).

### Fixed

- Fixed stale refs information leaked by `Vcs.Graph.set_ref` (#41, @mbarbin).
- Fixed some odoc warnings related to `Vcs_base` (#38, @mbarbin).
- Changed some exceptions raised by the `vcs` related libraries to the `Vcs.E` exception (#34, @mbarbin).

### Removed

- Removed `Vcs.For_test` and merged it into `Vcs_test_helpers` (#38, @mbarbin).
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
