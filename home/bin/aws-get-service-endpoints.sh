#!/usr/bin/env bash

# Requires user to be logged into AWS and set the AWS_PROFILE environment variable appropriately
# Currently results in the following error for certain services for unknown reasons
#  "An error occurred (ParameterNotFound) when calling the GetParameter operation"

function _getServiceList() {
    if [ $# -ne 2 ] || [ "$2" -lt "$1" ]; then
        printf "\e[0;31m[ERROR]\e[0m %s\n\e[0;34m[USAGE]\e[0m %s\n" "Service indicies must be provided." "aws-get-service-endpoints.sh <starting_service_zero_based_index> <ending_index>" >&2
        exit 1
    fi
    SERVICES=$( aws ssm get-parameters-by-path --path "/aws/service/global-infrastructure/services" --query 'Parameters[].Value' | jq -r '.[]' | sort | uniq )
    SERVICE_COUNT="$(echo "${SERVICES}" | wc -l | tr -d '[:blank:]')"
    DESIRED_COUNT=$(( $2 - $1 + 1 ))
    printf "\e[0;34m[INFO ]\e[0m %s\n" "Total number of services: ${SERVICE_COUNT}" >&2
    printf "\e[0;34m[INFO ]\e[0m %s\n" "Retrieving indicies $1 through $2 (${DESIRED_COUNT} service)." >&2
    SERVICES="$(echo "${SERVICES}" | tail -n "$(( SERVICE_COUNT - $1 ))" | head -n "${DESIRED_COUNT}" )"
    SERVICE_COUNT="$(echo "${SERVICES}" | wc -l)"
}

function _getAllEndpoints() {
    local i j
    i="0"
    _getServiceList "$@"
    while read -r SERVICE ; do
        i=$((i+1))
        j="0"
        REGIONS="$(aws ssm get-parameters-by-path --path "/aws/service/global-infrastructure/services/${SERVICE}/regions" --query 'Parameters[].Value' | jq -r '.[]' | sort | uniq )"
        REGION_COUNT="$(echo "${REGIONS}" | wc -l)"
        while read -r REGION ; do
            j=$((j+1))
            _printStatus "${SERVICE}" "${i}" "${REGION}" "${j}"
            aws ssm get-parameter --name "/aws/service/global-infrastructure/regions/${REGION}/services/${SERVICE}/endpoint" --query 'Parameter.Value' --output text || echo "${SERVICE} in ${REGION} returned an error"
        done <<< "${REGIONS}"
        printf "\n" >&2
    done <<< "${SERVICES}"
}

function _printStatus() {
    printf "\r\e[0;34m[INFO ]\e[0m Retrieving endpoints for %s (%03d/%03d). Region %02d of %02d" "${1}" "${2}" "${SERVICE_COUNT}" "${4}" "${REGION_COUNT}" >&2
}

printf "\e[0;34m[INFO ]\e[0m This script may take multiple hours to run. Please ensure that your credentials do not time out.\n"  >&2
_getAllEndpoints "$@" | sort | uniq
