# Cram tests for vcs

## Motivation

In this directory, we test the command line `volgo-vcs`. This command line is itself motivated by the desire to run exploratory tests using the vcs interface and the unix backends available on actual repositories.

What we aim for in these tests is to make sure that `volgo-vcs` is not broken in some ways, thus we would like to have good coverage of the commands it exposes.

This is not a test for `git` itself, and to the extent possible, the tests in this directory shall try to make little direct calls to git commands. Prefer minting a new `vcs` command that does what you need instead.

## Testing environment

### Limiting GitHub specifics

In the testing environment of GitHub workflow actions, it is necessary to take some extra steps to make the test work. We prefer not to rely on a solution involving using the config of the workflow itself, such as:

```yaml
steps:
    - name: Set up Git
        run: |
            git config --global user.email "test@example.com"
            git config --global user.name "Test User"
    - name: Run tests
        run: |
            # Your test commands here
```

The reason is because we'd also would like the tests to work when run with `dune` locally during development, and we prefer to limit special logic we have dedicated to the GitHub environment to a minimum and rather find ways to take steps that are applicable to all testing environments in use.

### Initialize git config

It is necessary to set some git config values. This may be done locally to the repo under test.

In the cram tests we'll do:

```sh
  $ git init . 2> /dev/null
  Initialized empty Git repository in $TESTCASE_ROOT/.git/

  $ git config user.name "Test User"
  $ git config user.email "test@example.com"
```

Or the equivalent in `vcs`:

```sh
  $ volgo-vcs init -q .
  $ volgo-vcs set-user-config --user.name "Test User" --user.email "test@example.com"
```

### Deterministic branch name

After the first commit, we run the following to force the branch name.

```sh
  $ git branch -m main
```

Or the equivalent in `vcs`:

```sh
  $ volgo-vcs rename-current-branch main
```

Note that it is not possible to run the following in the GitHub workflow actions before `git init` (this results in an error).

```sh
  $ git config init.defaultBranch <name>
```

And we do not want to make use of the `--global` for the reasons explained in the GitHub specifics part.
