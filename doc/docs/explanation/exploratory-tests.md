# Exploratory tests

The `volgo-vcs` opam package introduces an executable, `volgo-vcs`, designed to bring the core functionalities of the *volgo* packages directly to your command line.

It's a practical tool for conducting exploratory testing within your repositories, and reproducing bugs or issues externally, for a smoother debugging process. As a live code sample, it also demonstrates the use of the library.

Whether you're testing new features, diagnosing problems, or seeking to understand the library's application, `volgo-vcs` can be a useful resource.

:::warning[Not intended for stable scripts]

The `volgo-vcs` CLI is designed primarily for **exploratory testing and debugging** purposes. It is **not intended** to be consumed by stable scripts or automated pipelines.

**Output format instability**: The precise structure and formatting of the CLI output (including `--output-format` options like `Dyn`, `Json`, and `Sexp`) are subject to change over time without stability guarantees. We may modify, extend, or restructure the output in future releases without prior notice.

**Development standards**: This CLI component is generally developed with slightly less rigorous stability standards compared to the user-facing library APIs (such as `Vcs`, `Volgo`, etc.). While the code is thoroughly tested and functional, it remains somewhat experimental. You may encounter rough edges or behaviors that differ from your expectations.

**We welcome your feedback!** If you encounter issues, unexpected behaviors, or have suggestions for improvements, please don't hesitate to [open an issue](https://github.com/mbarbin/vcs/issues) on GitHub. Your bug reports and feedback help us improve this tool.

:::

Below is a quick overview of the commands available in `volgo-vcs`:

```bash
$ volgo-vcs --help=plain
NAME
       volgo-vcs - Call a command from the Vcs interface.

SYNOPSIS
       volgo-vcs COMMAND …

       This CLI is built with the Volgo libraries (Versatile OCaml Library
       for Git Operations). It is designed for exploratory testing and
       debugging of the Vcs packages.



       We expect a 1:1 mapping between the functions exposed in [Vcs.S] and
       the sub commands exposed here, plus additional ones.



       Several output formats are available via the --output-format option
       (json, sexp, dyn) to accommodate different workflows and tools during
       debugging sessions.



       STABILITY NOTICE: This CLI is not intended for stable scripting. Its
       output format and behavior may change between releases without
       stability guarantees. If you encounter issues or have suggestions,
       please open an issue at: https://github.com/mbarbin/vcs/issues

COMMANDS
       add [OPTION]… file
           Add a file to the index.

       branch-revision [--output-format=FORMAT] [OPTION]… [BRANCH]
           Get the revision of a branch.

       commit [--message=MSG] [--output-format=FORMAT] [--quiet] [OPTION]…
           Commit a file.

       current-branch [--output-format=FORMAT] [--opt] [OPTION]…
           Print the current branch.

       current-revision [--output-format=FORMAT] [OPTION]…
           Print the revision of HEAD.

       descendance [--output-format=FORMAT] [OPTION]… REV REV
           Print descendance relation between 2 revisions.

       find-enclosing-repo-root [--from=path/to/dir] [--output-format=FORMAT]
       [--store=VAL] [OPTION]…
           Find the root of the enclosing-repo.

       gca [--output-format=FORMAT] [OPTION]… [REV]…
           Print greatest common ancestors of revisions.

       git [OPTION]… [ARG]…
           Run the git cli.

       graph [--output-format=FORMAT] [OPTION]…
           Compute graph of current repo.

       hg [OPTION]… [ARG]…
           Run the hg cli.

       init [--output-format=FORMAT] [--quiet] [OPTION]… path/to/root
           Initialize a new repository.

       load-file [OPTION]… path/to/file
           Print a file from the filesystem (aka cat).

       log [--output-format=FORMAT] [OPTION]…
           Show the log of current repo.

       ls-files [--below=PATH] [OPTION]…
           List versioned file.

       name-status [--output-format=FORMAT] [OPTION]… BASE TIP
           Show a summary of the diff between 2 revs.

       num-status [--output-format=FORMAT] [OPTION]… BASE TIP
           Show a summary of the number of lines of diff between 2 revs.

       read-dir [--output-format=FORMAT] [OPTION]… path/to/dir
           Print the list of files in a directory.

       refs [--output-format=FORMAT] [OPTION]…
           Show the refs of current repo.

       rename-current-branch [OPTION]… branch
           Move/rename a branch to a new name.

       save-file [OPTION]… FILE
           Save stdin to a file from the filesystem (aka tee).

       set-user-config [--user.email=EMAIL] [--user.name=USER] [OPTION]…
           Changes some settings in the user config.

       show-file-at-rev [--rev=REV] [OPTION]… FILE
           Show the contents of file at a given revision.

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
