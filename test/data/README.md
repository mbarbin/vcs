# Data files

This directory contains some files that are used by tests.

## Repos source

Data files are the result of git commands run inside a clone of different repos, keeping the repo name as basename for the files.

The repos were chosen somewhat arbitrarily, or given as part of a bug report, etc. We can add more files from other repos as needed.

- [super-master-mind](https://github.com/mbarbin/super-master-mind)
- [eio](https://github.com/ocaml-multicore/eio.git)

## Files

### super-master-mind.log

This file was created by capturing the output of:

```sh
git log --all --pretty=format:'%H %P'
```

### super-master-mind.refs

This file was created by capturing the output of:

```sh
git show-refs
```

### super-master-mind.name-status

This file was created by capturing the output of:

```sh
git diff --name-status 1892d4980ee74945eb98f67be26b745f96c0f482..bcaf94757fe3cb247fa544445f0f41f3616943d7
```

### super-master-mind.num-status

This file was created by capturing the output of:

```sh
git diff --numstat 1892d4980ee74945eb98f67be26b745f96c0f482..bcaf94757fe3cb247fa544445f0f41f3616943d7
```

### eio.num-status

This file was created by capturing the output of:

```sh
git diff --numstat ef415fbdfe1c60cb046a89db4fd48663fc61b77e..3be614e86fb4c7b70f2547972491dd7fb170f01a
```
