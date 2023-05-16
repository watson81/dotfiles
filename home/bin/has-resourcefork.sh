#!/usr/bin/env sh

# ls -la@ "$*"
xattr -p com.apple.ResourceFork "$*" >/dev/null 2>&1
