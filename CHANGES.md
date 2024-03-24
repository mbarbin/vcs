## 0.0.2 (unreleased)

### Added

### Changed

### Deprecated

### Fixed

- Allow more characters when parsing branch names.

### Removed

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
