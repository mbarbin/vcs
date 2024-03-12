# Data files

This directory contains some files that are used by tests.

## Repo source

Files named `super-master-mind.*` are the result of git commands run inside a
clone of [this repo](https://github.com/mbarbin/super-master-mind).

It was chosen somewhat arbitrarily, as a repo with various branches and with a
bit of history. We can add more files as needed.

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