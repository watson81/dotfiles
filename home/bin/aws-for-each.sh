#!/usr/bin/env sh

# Check for standard AWS profiles, such as is used by AWS SSO
profiles=$(grep -E '^\[profile .+\]$' ~/.aws/config | sed -e 's/^\[profile //' -e 's/]$//')
# Fall back to using profiles originating in the credentials file (manual, SAML, etc.)
[ -z "${profiles}" ] && profiles=$(grep -E '^\[.+\]$' ~/.aws/credentials | sed -e 's/^\[//' -e 's/]$//')
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
