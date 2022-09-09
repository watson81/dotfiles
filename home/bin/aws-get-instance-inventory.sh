#!/usr/bin/env bash

set -e

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ACCOUNT_ALIAS=$(aws iam list-account-aliases --query AccountAliases[0] --output text)

aws ec2 describe-instances --query 'Reservations[*].Instances[*].{State:State.Name, InstanceId:InstanceId, PrivateDnsName:PrivateDnsName, Tags:Tags, ImageId:ImageId }' | \
    jq 'flatten | .[] | { InstanceId: .InstanceId , InstanceName: ( .Tags[] | select(.Key == "Name" ).Value ) , AccountId: "'"${ACCOUNT_ID}"'" , AccountAlias: "'"${ACCOUNT_ALIAS}"'" , Region: "'"${AWS_DEFAULT_REGION}"'" , State: .State, PrivateDnsName: .PrivateDnsName, ImageId: .ImageId, Tags: ( .Tags | reduce .[] as $tag (""; . + $tag.Key + "=" + $tag.Value + "|") ) }'
