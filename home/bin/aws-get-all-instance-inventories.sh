#!/usr/bin/env bash

read -rep "Re-login to all AWS accounts? [Y] " -n 1  DO_LOGIN
[ -z "${DO_LOGIN}" ] || [ "${DO_LOGIN,,}" = "y" ] && ! aws-login-all.sh && exit 1

FINAL_FILE="$(date +%FT%T%z | tr : _ ) Kabbage AWS Instance Inventory.csv"
TMP_FILE="$(mktemp)"

echo "Getting instance inventories" >&2
if ! aws-for-each.sh aws-get-instance-inventory.sh > "${TMP_FILE}" ; then
    echo "Failed to get instance inventory. Check ${TMP_FILE}" >&2
elif ! json-to-csv.sh "${TMP_FILE}" > "${FINAL_FILE}" ; then
    echo "Failed to convert JSON to CSV. Check ${TMP_FILE}" >&2
else
    rm "${TMP_FILE}"
fi
