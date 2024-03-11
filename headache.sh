#!/bin/bash -e

dirs=(
    "bin"
    "lib/git_cli/src"
    "lib/git_cli/test"
    "lib/vcs/src"
    "lib/vcs/test"
    "lib/vcs_command/src"
    "lib/vcs_command/test"
    "lib/vcs_for_test/src"
    "lib/vcs_for_test/test"
    "lib/vcs_git/src"
    "lib/vcs_git/test"
    "lib/vcs_git_blocking/src"
    "lib/vcs_git_blocking/test"
    "lib/vcs_param/src"
    "lib/vcs_param/test"
    # add more directories here
)

for dir in "${dirs[@]}"; do
    # Apply headache to .ml files
    headache -c .headache.config -h COPYING.HEADER ${dir}/*.ml

    # Check if .mli files exist in the directory, if so apply headache
    if ls ${dir}/*.mli 1> /dev/null 2>&1; then
        headache -c .headache.config -h COPYING.HEADER ${dir}/*.mli
    fi
done

dune fmt
