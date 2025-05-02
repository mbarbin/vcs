#!/bin/bash -e

dirs=(
    # Add new directories below:
    "bin"
    "example"
    "lib/vcs/src"
    "lib/vcs/test"
    "lib/vcs_base/src"
    "lib/vcs_base/test"
    "lib/vcs_cli/src"
    "lib/vcs_cli/test"
    "lib/vcs_git_unix/src"
    "lib/vcs_git_unix/test"
    "lib/vcs_git_eio/src"
    "lib/vcs_git_eio/test"
    "lib/vcs_git_backend/src"
    "lib/vcs_git_backend/test"
    "lib/vcs_test_helpers/src"
    "lib/vcs_test_helpers/test"
    "test/expect"
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
