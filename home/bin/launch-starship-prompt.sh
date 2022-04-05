#!/usr/bin/env bash
if [[ ${BASH_VERSINFO[0]} -le 2 ]]; then
    echo "Bash 3+ is required" >&2
elif [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    eval "$(starship init bash)"
else
    echo "This script should be sourced, not run. Try:"
    echo ". ${BASH_SOURCE[0]}"
fi
