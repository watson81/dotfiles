#!/usr/bin/env bash

if [[ -n ${http_proxy} ]] ; then URL=${http_proxy}
elif [[ -n ${https_proxy} ]] ; then URL=${https_proxy}
elif [[ -n ${HTTP_PROXY} ]] ; then URL=${HTTP_PROXY}
elif [[ -n ${HTTPS_PROXY} ]] ; then URL=${HTTPS_PROXY}
elif [[ -n ${all_proxy} ]] ; then URL=${all_proxy}
elif [[ -n ${ALL_PROXY} ]] ; then URL=${ALL_PROXY}
else
    exit 1
fi

if [[ ${URL} =~ ^(https?://)?[^/@:]+:[^/@]+@[^/]+\.[^/]+ ]] ; then
    # Authenticated proxy
    printf "%s" ''
elif [[ ${URL} =~ ^(https?://)?[^/]+\.[^/]+ ]] ; then
    # Unauthenticated proxy
    printf "%s" ''
else
    # Invalid value
    exit 2
fi
exit 0
