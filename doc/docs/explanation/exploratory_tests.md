# Exploratory tests

The `vcs-command` package introduces an executable, `ocaml-vcs`, designed to bring the core functionalities of ocaml-vcs directly to your command line.

It's a practical tool for conducting exploratory testing within your repositories, and reproducing bugs or issues externally, for a smoother debugging process. As a live code sample, it also demonstrates the use of the library.

Whether you're testing new features, diagnosing problems, or seeking to understand the library's application, `ocaml-vcs` can be a useful resource.

Below is a quick overview of the commands available in `ocaml-vcs`:

```bash
$ ocaml-vcs --help=plain
NAME
       ocaml-vcs - call a command from the vcs interface

SYNOPSIS
       ocaml-vcs COMMAND …



       This is an executable to test the Version Control System (vcs)
       library.



       We expect a 1:1 mapping between the function exposed in the [Vcs.S]
       and the sub commands exposed here, plus additional functionality in
       [more-tests].



COMMANDS
       add [OPTION]… file
           add a file to the index

       commit [--message=MSG] [--quiet] [OPTION]…
           commit a file

       current-branch [OPTION]…
           current branch

       current-revision [OPTION]…
           revision of HEAD

       git [OPTION]… [ARG]…
           run the git cli

       graph [OPTION]…
           compute graph of current repo

       init [--quiet] [OPTION]… file
           initialize a new repository

       load-file [OPTION]… file
           print a file from the filesystem (aka cat)

       log [OPTION]…
           show the log of current repo

       ls-files [--below=PATH] [OPTION]…
           list file

       more-tests COMMAND …
           more tests combining vcs functions

       name-status [OPTION]… rev rev
           show a summary of the diff between 2 revs

       num-status [OPTION]… rev rev
           show a summary of the number of lines of diff between 2 revs

       refs [OPTION]…
           show the refs of current repo

       rename-current-branch [OPTION]… branch
           move/rename a branch to a new name

       save-file [OPTION]… file
           save stdin to a file from the filesystem (aka tee)

       set-user-config [--user.email=EMAIL] [--user.name=USER] [OPTION]…
           set the user config

       show-file-at-rev [--rev=REV] [OPTION]… file
           show the contents of file at a given revision

COMMON OPTIONS
       --help[=FMT] (default=auto)
           Show this help in format FMT. The value FMT must be one of auto,
           pager, groff or plain. With auto, the format is pager or plain
           whenever the TERM env var is dumb or undefined.

       --version
           Show version information.

EXIT STATUS
       ocaml-vcs exits with:

       0   on success.

       123 on indiscriminate errors reported on standard error.

       124 on command line parsing errors.

       125 on unexpected internal errors (bugs).

```
