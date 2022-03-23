#!/usr/bin/env sh

profiles=$(grep -E '^\[.+\]$' ~/.aws/credentials | sed -e 's/^\[//' -e 's/]$//')
regions="${AWS_ACTIVE_REGIONS:-${AWS_DEFAULT_REGION:-us-east-1}}"

export AWS_PROFILE
export AWS_DEFAULT_REGION

# put this in a function so we can easy return a value
iterate() {
    RC=1

    for AWS_PROFILE in ${profiles} ; do
        for AWS_DEFAULT_REGION in ${regions} ; do
            bash -c "$*"
            RC=$?
        done
    done

    return $RC
}

iterate "$@"
