#!/bin/bash

version=75061cb060cb9337292391d1afc4802559678d5c

set -e -o pipefail

TMP="$(mktemp -d)"
trap "rm -rf $TMP" EXIT

rm -rf expect-test-helpers
mkdir -p expect-test-helpers/src

(
    cd $TMP
    git clone https://github.com/mbarbin/expect-test-helpers.git
    cd expect-test-helpers
    git checkout $version
)

SRC=$TMP/expect-test-helpers

cp -v $SRC/LICENSE{,.janestreet} expect-test-helpers/
cp -v -R $SRC/src expect-test-helpers/

git checkout expect-test-helpers/src/dune
git add -A .
