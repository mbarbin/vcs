#!/bin/bash

version=7935ebe1a97cf9618835d0b682fcf14fa784fdd5

set -e -o pipefail

TMP="$(mktemp -d)"
trap "rm -rf $TMP" EXIT

rm -rf eio-writer
mkdir -p eio-writer/src

(
    cd $TMP
    git clone https://github.com/mbarbin/eio-writer.git
    cd eio-writer
    git checkout $version
)

SRC=$TMP/eio-writer

cp -v $SRC/LICENSE{,.janestreet} eio-writer/
cp -v -R $SRC/src eio-writer/

git checkout eio-writer/src/dune
git checkout eio-writer/src/vcs_eio_writer.ml
git add -A .
