#!/usr/bin/env bash

[ "${BASH_VERSINFO:-0}" -lt 4 ] && echo "Requires Bash 4+" && exit # for associative arrays and parameter expansion

! hash saml2aws 2>/dev/null && echo "Requires saml2aws" && exit

[ -r "${HOME}/.aws/available-roles.sh" ] && . "${HOME}/.aws/available-roles.sh" 

if [ "${#KBG_AWS_ROLES[*]}" -lt "1" ]; then
    echo "Requires a list of roles in the associative array KBG_AWS_ROLES."
    echo "Try defining in ~/.aws/available-roles.sh"
    exit
fi

function promptYN {
    # $1 prompt
    # returns entered text in $REPLY. If Y or y, return code is zero. Else return code is non-zero
    printf "$@"
    read -rp " (Y/N) [N] " -n 1
    [ -n "${REPLY}" ] && echo
    [ -n "${REPLY}" ] && [ "${REPLY,,}" = "y" ]
}

promptYN "Reset AWS sessions?" && rm -Pf ~/.aws/credentials

for arn in "${KBG_AWS_ROLES[@]}"; do
    accountid=$(echo "$arn" | sed -r 's/^([^:]*:){4}([^:]+).+/\2/')
    role=$(echo "$arn" | sed -r 's/^([^:]*:){5}role\/(.+)/\2/')
    account=$(aws-accountid-to-name.sh "${accountid}")
    if promptYN "Log into \e[1;33m%s\e[0m as \e[1;32m%s\e[0m?" "${account}" "${role}" ; then
        printf "Logging into \e[0;36m%s\e[0m\n" "${arn}"
        saml2aws login --skip-prompt --duo-mfa-option="Duo Push" --force --role="${arn}" --profile="${account}" --quiet "$@"
    fi
done
