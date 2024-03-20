#!/bin/bash

version=8e19e6b216fff5329f2e34c40a185f577d789c3f

set -e -o pipefail

TMP="$(mktemp -d)"
trap "rm -rf $TMP" EXIT

rm -rf eio-process
mkdir -p eio-process/src

(
    cd $TMP
    git clone https://github.com/mbarbin/eio-process.git
    cd eio-process
    git checkout $version
)

SRC=$TMP/eio-process

cp -v $SRC/LICENSE{,.janestreet,.eio} eio-process/
cp -v -R $SRC/src eio-process/

git checkout eio-process/src/dune
git checkout eio-process/src/vcs_eio_process.ml
git add -A .
