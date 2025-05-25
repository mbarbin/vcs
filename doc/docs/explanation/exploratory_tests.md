# Exploratory tests

The `vcs-cli` package introduces an executable, `volgo-vcs`, designed to bring the core functionalities of the *volgo* packages directly to your command line.

It's a practical tool for conducting exploratory testing within your repositories, and reproducing bugs or issues externally, for a smoother debugging process. As a live code sample, it also demonstrates the use of the library.

Whether you're testing new features, diagnosing problems, or seeking to understand the library's application, `volgo-vcs` can be a useful resource.

Below is a quick overview of the commands available in `volgo-vcs`:

```bash
$ volgo-vcs --help=plain
NAME
       volgo-vcs - call a command from the vcs interface

SYNOPSIS
       volgo-vcs COMMAND …



       This is an executable to test the Version Control System (vcs)
       library.



       We expect a 1:1 mapping between the function exposed in the [Vcs.S]
       and the sub commands exposed here, plus additional ones.



COMMANDS
       add [OPTION]… file
           add a file to the index

       branch-revision [OPTION]… [BRANCH]
           revision of a branch

       commit [--message=MSG] [--quiet] [OPTION]…
           commit a file

       current-branch [OPTION]…
           current branch

       current-revision [OPTION]…
           revision of HEAD

       descendance [OPTION]… REV REV
           print descendance relation between 2 revisions

       find-enclosing-repo-root [--from=path/to/dir] [--store=VAL]
       [OPTION]…
           find enclosing repo root

       gca [OPTION]… [REV]…
           print greatest common ancestors of revisions

       git [OPTION]… [ARG]…
           run the git cli

       graph [OPTION]…
           compute graph of current repo

       init [--quiet] [OPTION]… path/to/root
           initialize a new repository

       load-file [OPTION]… path/to/file
           print a file from the filesystem (aka cat)

       log [OPTION]…
           show the log of current repo

       ls-files [--below=PATH] [OPTION]…
           list file

       name-status [OPTION]… BASE TIP
           show a summary of the diff between 2 revs

       num-status [OPTION]… BASE TIP
           show a summary of the number of lines of diff between 2 revs

       read-dir [OPTION]… path/to/dir
           print the list of files in a directory

       refs [OPTION]…
           show the refs of current repo

       rename-current-branch [OPTION]… branch
           move/rename a branch to a new name

       save-file [OPTION]… FILE
           save stdin to a file from the filesystem (aka tee)

       set-user-config [--user.email=EMAIL] [--user.name=USER] [OPTION]…
           set the user config

       show-file-at-rev [--rev=REV] [OPTION]… FILE
           show the contents of file at a given revision

COMMON OPTIONS
       --help[=FMT] (default=auto)
           Show this help in format FMT. The value FMT must be one of auto,
           pager, groff or plain. With auto, the format is pager or plain
           whenever the TERM env var is dumb or undefined.

       --version
           Show version information.

EXIT STATUS
       volgo-vcs exits with:

       0   on success.

       123 on indiscriminate errors reported on standard error.

       124 on command line parsing errors.

       125 on unexpected internal errors (bugs).

```
