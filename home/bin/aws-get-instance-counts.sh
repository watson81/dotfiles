#!/usr/bin/env bash

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ACCOUNT_ALIAS=$(aws iam list-account-aliases --query AccountAliases[0] --output text)

EC2_STATES=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].{State:State.Name}' | \
    jq 'flatten | reduce .[].State as $state ( [[.[].State] | unique | {(.[]): 0}] | add; setpath([$state] ; .[$state] + 1))')
if [ "$EC2_STATES" == "null" ] ; then
    EC2_STATES=""
else
    EC2_STATES=$(echo "${EC2_STATES}" | jq '. | with_entries(.key = "ec2-total-" + .key)')
fi

EB_STATES=$(aws ec2 describe-instances --filters "Name=tag-key,Values=elasticbeanstalk:environment-id" --query 'Reservations[*].Instances[*].{State:State.Name}' | \
    jq 'flatten | reduce .[].State as $state ( [[.[].State] | unique | {(.[]): 0}] | add; setpath([$state] ; .[$state] + 1))')
if [ "$EB_STATES" == "null" ] ; then
    EB_STATES=""
else
    EB_STATES=$(echo "${EB_STATES}" | jq '. | with_entries(.key = "elastic-beanstalk-" + .key)')
fi

# generates state counts of form <EKS-CLUSTER-NAME>-<STATE>. e.g. "eks-cluster-running"
# magic values [22:52] are based on tag prefix kubernetes.io/cluster/ being 22 characters and any reasonable cluster name being < 30 characters in length
# shellcheck disable=SC2016
EKS_STATES="$(aws ec2 describe-instances --filters "Name=tag:role,Values=eks-worker" --query 'Reservations[*].Instances[*].{State:State.Name, Cluster:Tags[?starts_with(Key,`kubernetes.io/cluster/`)]|[0].Key}' | \
    jq '[. | flatten | .[] | { State: (.Cluster[22:52]+"-"+.State)}] | reduce .[].State as $state ( [[.[].State] | unique | {(.[]): 0}] | add; setpath([$state] ; .[$state] + 1))' )"

echo "${EC2_STATES} ${EB_STATES} ${EKS_STATES}" | jq -s '. | add | setpath(["Account Name"];"'"${ACCOUNT_ALIAS}"'") | setpath(["Account Id"];"'"${ACCOUNT_ID}"'") | setpath(["Region"];"'"${AWS_DEFAULT_REGION}"'")'
