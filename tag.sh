#!/bin/sh
git tag -d $1
git push origin :refs/tags/$1
git tag -a $1 -m "tag ${1}"
git push --tags
