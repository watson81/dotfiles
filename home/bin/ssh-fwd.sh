#!/usr/bin/env bash

print_usage() {
    cat >&2 <<EOF
usage: ssh-fwd [--[no-]interactive] [--[no-]ssh] [--[no-]gpg]
               [--remote-gpg /path/to/S.gpg-agent]
               [--local-gpg /path/to/S.gpg-agent.extra]
               [user@]destination [ssh parameter ...]

  Starts a ssh connection with optional ssh-agent or gpg-agent forwarding.
  If in interactive mode (the default), it will prompt for any missing parameters.
  You must pass in a destination identifiable to ssh, such as a host name.
  A user may optionally be part of the destination.
  Any parameters following the destination will be passed through to ssh.

  If remote gpg issues errors similar to "Inappropriate ioctl for device" then
  you may need to install a different pinentry program. For macs, \`brew install pinentry-mac\`
EOF
}

err() {
    echo "$*" >&2
}

promptYN() {
    # $1 prompt
    # returns entered text in $REPLY. If Y or y, return code is zero. Else return code is non-zero
    printf "$@"
    read -rp " (Y/N) [N] " -n 1
    [ -n "${REPLY}" ] && echo
    [ -n "${REPLY}" ] && [ "${REPLY,,}" = "y" ]
}

parseSocketPath() {
    sed -n "s/^${1:-agent-extra-socket}:\(.*\)/\1/p"
}

INTERACTIVE="YES"
SSH_AGENT=""
GPG_AGENT=""
LOCAL_GPG=""
REMOTE_GPG=""

set -o pipefail

while [[ -n "$1" ]]; do
    case ${1,,} in
            --no-interactive )  INTERACTIVE="NO"
                                ;;
            --interactive )     INTERACTIVE="YES"
                                ;;
            --no-ssh )          SSH_AGENT="NO"
                                ;;
            --ssh )             SSH_AGENT="YES"
                                ;;
            --no-gpg )          GPG_AGENT="NO"
                                ;;
            --gpg )             GPG_AGENT="YES"
                                ;;
            --local-gpg )       shift
                                if [ -z "$1" ] ; then
                                    err The path to your local gpg agent socket must be provided with the local-gpg flag
                                    print_usage
                                    exit 1
                                fi
                                GPG_AGENT="YES"
                                LOCAL_GPG=$1
                                ;;
            --remote-gpg )      shift
                                if [ -z "$1" ] ; then
                                    err The desired remote path to the remote gpg socket must be provided with the remote-gpg flag
                                    print_usage
                                    exit 1
                                fi
                                GPG_AGENT="YES"
                                REMOTE_GPG=$1
                                ;;
        -h | --help )           print_usage
                                exit
                                ;;
        -* )                    err "Error: unrecognized parameter: $1"
                                print_usage
                                exit 1
                                ;;
        * )                     SSH_DESTINATION=$1
                                shift
                                break
                                ;;
    esac
    shift
done
[[ -z "$SSH_DESTINATION" ]] && err "Error: missing SSH destination parameter" && print_usage && exit 1

if [[ ${INTERACTIVE^^} == YES ]] ; then
    [[ -z ${SSH_AGENT} ]] && promptYN "Forward SSH Agent?" && SSH_AGENT=YES
    [[ ${SSH_AGENT^^} == NO ]] && SSH_AGENT=""

    [[ -z ${GPG_AGENT} ]] && promptYN "Forward GPG Agent?" && GPG_AGENT=YES
    [[ ${GPG_AGENT^^} == NO ]] && GPG_AGENT=""
fi

[[ -n "${SSH_AGENT}" ]] && SSH_AGENT=-A

if [[ -n "${GPG_AGENT}" ]]; then
    # make sure gpg-agent is running locally
    gpg-connect-agent -q /bye || { err "WARNING: could not verify that gpg-agent is running." ; }

    # find the local extra socket and validate it
    if [[ -z "${LOCAL_GPG}" ]] ; then
        if ! LOCAL_GPG=$(gpgconf --list-dirs | parseSocketPath agent-extra-socket ) ; then
            err "Could not determine local gpg socket path"
            exit 3
        fi
    fi
    [[ -n "${LOCAL_GPG}" && ! -S "${LOCAL_GPG}" ]] && { err "Local GPG path \"${LOCAL_GPG}\" is not a Unix Socket." ; exit 2 ; }

    # find out what path we should use on the remote server
    if [[ -z "${REMOTE_GPG}" ]]; then
        if ! REMOTE_GPG=$({ ssh "${SSH_DESTINATION}" gpgconf --dry-run --list-dirs ; } | parseSocketPath agent-socket ) ; then
            err "Could not determine remote gpg socket path"
            exit 4
        fi
    fi

    # make sure gpg-agent is not running remotely
    ssh "${SSH_DESTINATION}" bash -c "'gpgconf --quiet --kill gpg-agent ; \[ -S ${REMOTE_GPG} \] && rm ${REMOTE_GPG}'"

    # shellcheck disable=SC2029
    ssh ${SSH_AGENT} -R "${REMOTE_GPG}:${LOCAL_GPG}" "${SSH_DESTINATION}" "$*"
else
    # shellcheck disable=SC2029
    ssh ${SSH_AGENT} "${SSH_DESTINATION}" "$*"
fi
