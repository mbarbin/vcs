# Parametrization Axes

One of the core strengths of the Vcs library is its versatility: users can tailor their experience along several independent axes, depending on their needs and environment. We refer to these as **parametrization axes** — distinct dimensions along which you can configure or compose the library.

## 1. Blocking vs Non-blocking

Vcs supports both blocking and non-blocking (concurrent) execution models.
- **Blocking:** Uses OCaml’s standard library for IO, suitable for scripts or environments where concurrency is not required.
- **Non-blocking:** Uses [Eio](https://github.com/ocaml-multicore/eio) for efficient, direct-style concurrency.

## 2. Git vs Mercurial Compatibility

While Vcs is Git-centric, it offers a compatibility mode for Mercurial repositories.
- **Git:** Full feature set, native semantics.
- **Mercurial:** Git operations are mapped to Mercurial where possible, with clear documentation of limitations.

## 3. Base vs Stdlib

You can choose whether to use the [Base](https://github.com/janestreet/base) library or stick with OCaml’s standard library.
- **vcs-base:** Integrates with Jane Street’s Base library ecosystem.
- **vcs:** Uses only OCaml’s standard library for maximum compatibility.

## 4. Exception-raising vs Result-based APIs

Vcs provides both exception-raising and result-returning APIs, so you can pick the error-handling style that best fits your codebase.
- **Raising:** Functions may throw exceptions on error.
- **Result-based:** Functions return `('a, error) result` types for explicit error handling.

---

These axes can be combined independently, aiming to make Vcs a truly versatile OCaml library for Git (and partially Mercurial) operations. This flexibility is the inspiration behind the “Versatile” in the project’s name.

If you have suggestions for additional parametrization axes or want to discuss best practices, please open an issue or join the discussion on GitHub!
