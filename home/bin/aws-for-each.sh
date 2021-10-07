#!/usr/bin/env sh

profiles=$(grep -E '^\[.+\]$' ~/.aws/credentials | sed -e 's/^\[//' -e 's/]$//')

export AWS_PROFILE
for AWS_PROFILE in ${profiles} ; do
    bash -c "$*"
done
