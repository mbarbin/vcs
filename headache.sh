#!/bin/bash -e

dirs=(
    "bin"
    "example"
    "lib/vcs/src"
    "lib/vcs/test"
    "lib/vcs_command/src"
    "lib/vcs_command/test"
    "lib/vcs_git_blocking/src"
    "lib/vcs_git_blocking/test"
    "lib/vcs_git_eio/src"
    "lib/vcs_git_eio/test"
    "lib/vcs_git_provider/src"
    "lib/vcs_git_provider/test"
    "lib/vcs_test_helpers/src"
    "lib/vcs_test_helpers/test"
    "test/expect"
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
