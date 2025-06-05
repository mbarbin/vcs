#!/bin/bash -e

dirs=(
    # Add new directories below:
    "bin"
    "example"
    "lib/volgo/src"
    "lib/volgo/test"
    "lib/volgo_base/src"
    "lib/volgo_base/test"
    "lib/volgo_vcs_cli/src"
    "lib/volgo_vcs_cli/test"
    "lib/volgo_git_backend/src"
    "lib/volgo_git_backend/test"
    "lib/volgo_git_unix/src"
    "lib/volgo_git_unix/test"
    "lib/volgo_git_eio/src"
    "lib/volgo_git_eio/test"
    "lib/volgo_hg_backend/src"
    "lib/volgo_hg_backend/test"
    "lib/volgo_hg_unix/src"
    "lib/volgo_hg_unix/test"
    "lib/volgo_hg_eio/src"
    "lib/volgo_hg_eio/test"
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
