# Exploratory tests

The `vcs-command` package introduces an executable, `ocaml-vcs`, designed to bring the core functionalities of ocaml-vcs directly to your command line.

It's a practical tool for conducting exploratory testing within your repositories, and reproducing bugs or issues externally, for a smoother debugging process. As a live code sample, it also demonstrates the use of the library.

Whether you're testing new features, diagnosing problems, or seeking to understand the library's application, `ocaml-vcs` can be a useful resource.

Below is a quick overview of the commands available in `ocaml-vcs`:

```bash
$ ocaml-vcs help -expand-dots -flags -recursive
call a command from the vcs interface

  ocaml-vcs SUBCOMMAND

This is an executable to test the Version Control System (vcs) library.

We expect a 1:1 mapping between the function exposed in the [Vcs.S] and the
sub commands exposed here, plus additional functionality in [more-tests].

=== subcommands and flags ===

  add                        . add a file to the index
  commit                     . commit a file
  commit --message MSG, -m   . commit message
  commit [--quiet], -q       . suppress output on success
  current-branch             . current branch
  current-revision           . revision of HEAD
  git                        . run the git cli
  git [--]                   . pass the remaining args to git
  init                       . initialize a new repository
  init [--quiet], -q         . suppress output on success
  load-file                  . print a file from the filesystem (aka cat)
  log                        . show the log of current repo
  ls-files                   . list file
  ls-files [--below PATH]    . only below path
  more-tests                 . more tests combining vcs functions
  more-tests branch-revision . revision of a branch
  more-tests gca             . print greatest common ancestors of revisions
  name-status                . show a summary of the diff between 2 revs
  num-status                 . show a summary of the number of lines of diff
                               between 2 revs
  refs                       . show the refs of current repo
  rename-current-branch      . move/rename a branch to a new name
  save-file                  . save stdin to a file from the filesystem (aka
                               tee)
  set-user-config            . set the user config
  set-user-config --user.email EMAIL
                             . user email
  set-user-config --user.name USER
                             . user name
  show-file-at-rev           . show the contents of file at a given revision
  show-file-at-rev --rev REV, -r
                             . revision
  tree                       . compute tree of current repo
  version                    . print version information
  version [-build-info]      . print build info for this build
  version [-version]         . print the version of this build
  help                       . explain a given subcommand (perhaps recursively)
  help [-expand-dots]        . expand subcommands in recursive help
  help [-flags]              . show flags as well in recursive help
  help [-recursive]          . show subcommands of subcommands, etc.

```
