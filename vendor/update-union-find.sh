#!/bin/bash

version=fd01bbd95ea4bc61e3a999fe4c83c46115a31635

set -e -o pipefail

TMP="$(mktemp -d)"
trap "rm -rf $TMP" EXIT

rm -rf union-find
mkdir -p union-find/src

(
    cd $TMP
    git clone https://github.com/mbarbin/union-find.git
    cd union-find
    git checkout $version
)

SRC=$TMP/union-find

cp -v $SRC/LICENSE{,.janestreet} $SRC/MLton-LICENSE union-find/
cp -v -R $SRC/src union-find/

git checkout union-find/src/dune
git checkout union-find/src/vcs_union_find.ml
git add -A .
