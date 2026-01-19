In the root dune-project I removed `fpath` and set the implicit transitive deps
to `false`.

fpath is a transitive deps of fpath-sexp0 which is listed.

In my path, `dune-pkg` is a recent nightly built of dune.

```sh
$ dune-pkg build --display=short --workspace=dune-workspace-5.3
$ echo $?  e
0
```

But:
```sh
$ opam-dune-lint
vcs-test-helpers.opam: OK
volgo-base.opam: OK
volgo-dev.opam: OK
volgo-git-backend.opam: OK
volgo-git-eio.opam: OK
volgo-git-unix.opam: OK
volgo-hg-backend.opam: OK
volgo-hg-eio.opam: OK
volgo-hg-unix.opam: OK
volgo-tests.opam: OK
volgo-vcs.opam: OK
volgo.opam: changes needed:
  "fpath" {>= "0.7.3"}                     [from src/volgo]
Note: version numbers are just suggestions based on the currently installed version.
Write changes? [y] ^C
```
