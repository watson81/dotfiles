#!/usr/bin/env bash

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ACCOUNT_ALIAS=$(aws iam list-account-aliases --query AccountAliases[0] --output text)

INFO=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].{ID:InstanceId, State:State.Name, Tags:Tags}' | \
    jq 'flatten | reduce .[].State as $state ( [[.[].State] | unique | {(.[]): 0}] | add; setpath([$state] ; .[$state] + 1)) | setpath(["Account Name"];"'"${ACCOUNT_ALIAS}"'") | setpath(["Account Id"];"'"${ACCOUNT_ID}"'")')

# for JSON
echo "${INFO}"