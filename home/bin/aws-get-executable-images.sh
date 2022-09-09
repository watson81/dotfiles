#!/usr/bin/env bash

set -e

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ACCOUNT_ALIAS=$(aws iam list-account-aliases --query AccountAliases[0] --output text)

QUERY_ARG='Images[*].{ImageId:ImageId,OwnerId:OwnerId,OwnerName:ImageOwnerAlias,Name:Name,Description:Description}'
COMMON_CMD="aws ec2 describe-images --no-paginate --query ${QUERY_ARG}"

OWNED_IMAGES=$( ${COMMON_CMD} --owners "${ACCOUNT_ID}" )
SUBSCRIBED_IMAGES=$( ${COMMON_CMD} --executable-users "${ACCOUNT_ID}" )

echo "${OWNED_IMAGES} ${SUBSCRIBED_IMAGES}" | jq -s 'flatten | .[] += {"Account Name": "'"${ACCOUNT_ALIAS}"'", "Account Id": "'"${ACCOUNT_ID}"'", "Region": "'"${AWS_DEFAULT_REGION}"'" } | .[]'
