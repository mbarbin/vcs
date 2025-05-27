#!/bin/bash -e

dirs=(
    # Add new directories below:
    "bin"
    "example"
    "lib/vcs_test_helpers/src"
    "lib/vcs_test_helpers/test"
    "lib/volgo/src"
    "lib/volgo/test"
    "lib/volgo_base/src"
    "lib/volgo_base/test"
    "lib/volgo_git_backend/src"
    "lib/volgo_git_backend/test"
    "lib/volgo_git_eio/src"
    "lib/volgo_git_eio/test"
    "lib/volgo_git_miou/src"
    "lib/volgo_git_miou/test"
    "lib/volgo_git_unix/src"
    "lib/volgo_git_unix/test"
    "lib/volgo_vcs_cli/src"
    "lib/volgo_vcs_cli/test"
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
