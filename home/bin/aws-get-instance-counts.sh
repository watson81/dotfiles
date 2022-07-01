#!/usr/bin/env bash

set -e

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ACCOUNT_ALIAS=$(aws iam list-account-aliases --query AccountAliases[0] --output text)

# Backticks are a property of the AWS query language; I'm not trying to run a subshell
# shellcheck disable=SC2016
EC2_DATA=$( aws ec2 describe-instances --query 'Reservations[].Instances[].{
                State:State.Name,
                Cluster:Tags[?starts_with(Key,`kubernetes.io/cluster/`)]|[0].Key,
                EB:Tags[?Key==`elasticbeanstalk:environment-id`]|[0].Value
            }' )

# This initiallizes an object with each unique state as a field = 0. Then it adds 1 to the field for each entry with that state
EC2_STATES=$(echo "${EC2_DATA}" | 
     jq 'reduce .[].State as $state ( [[.[].State] | unique | {(.[]): 0}] | add; setpath([$state] ; .[$state] + 1))')
if [ "$EC2_STATES" == "null" ] ; then
    EC2_STATES=""
else
    EC2_STATES=$(echo "${EC2_STATES}" | jq '. | with_entries(.key = "ec2-total-" + .key)')
fi

# This does the same, but only for inputs containing a non-null EB field
EB_STATES=$(echo "${EC2_DATA}" | 
    jq ' [.[] | select(.EB) | .State] |
        reduce .[] as $state ( [. | unique | {(.[]): 0}] | add; setpath([$state] ; .[$state] + 1))' )
if [ "$EB_STATES" == "null" ] ; then
    EB_STATES=""
else
    EB_STATES=$(echo "${EB_STATES}" | jq '. | with_entries(.key = "elastic-beanstalk-" + .key)')
fi

# This selects only nodes with non-null EKS cluster name.
# Then it makes a state based on the EKS cluster name and the state. e.g. "eks-cluster-running"
# magic values [22:52] are based on tag prefix kubernetes.io/cluster/ being 22 characters and any reasonable cluster name being < 30 characters in length
# Then it sums everything just like before
EKS_STATES=$(echo "${EC2_DATA}" |
    jq '[.[] | select(.Cluster) | { State: (.Cluster[22:52]+"-"+.State)}] | reduce .[].State as $state ( [[.[].State] | unique | {(.[]): 0}] | add; setpath([$state] ; .[$state] + 1))' )

echo "${EC2_STATES} ${EB_STATES} ${EKS_STATES}" | jq -s '. | add | setpath(["Account Name"];"'"${ACCOUNT_ALIAS}"'") | setpath(["Account Id"];"'"${ACCOUNT_ID}"'") | setpath(["Region"];"'"${AWS_DEFAULT_REGION}"'")'
