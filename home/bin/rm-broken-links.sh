#!/usr/bin/env sh
find . -type l ! -exec test -e {} \; -ok rm {} \;
