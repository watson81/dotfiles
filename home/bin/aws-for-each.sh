#!/usr/bin/env sh

profiles=$(grep -E '^\[.+\]$' ~/.aws/credentials | sed -e 's/^\[//' -e 's/]$//')
regions="${AWS_DEFAULT_REGION:-us-east-1}"

export AWS_PROFILE
export AWS_DEFAULT_REGION
for AWS_PROFILE in ${profiles} ; do
    for AWS_DEFAULT_REGION in ${regions} ; do
        bash -c "$*"
    done
done
