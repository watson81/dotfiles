#!/bin/sh
# This file is read by any shell and should contain generic environment variable settings

PATH=${PATH}:~/bin

# Figure out what OS this is being run on
# Inspired by GNU's config.guess from the config project (http://savannah.gnu.org/projects/config/)
UNAME_MACHINE=`(uname -m) 2>/dev/null` || UNAME_MACHINE=unknown
UNAME_RELEASE=`(uname -r) 2>/dev/null` || UNAME_RELEASE=unknown
UNAME_SYSTEM=`(uname -s) 2>/dev/null`  || UNAME_SYSTEM=unknown
UNAME_VERSION=`(uname -v) 2>/dev/null` || UNAME_VERSION=unknown

export HOMESHICK_DIR

case "$UNAME_MACHINE:$UNAME_SYSTEM:$UNAME_RELEASE:$UNAME_VERSION" in
    *:Darwin:*:*)
        UNAME_PROCESSOR=`uname -p` || UNAME_PROCESSOR=unknown

        if command -v brew >/dev/null; then
            HOMESHICK_DIR="$(brew --prefix)/opt/homeshick"

            if [ -d "$(brew --prefix)/opt/openssl/bin" ]; then
                PATH="$(brew --prefix)/opt/openssl/bin":$PATH
            fi
        else
            HOMESHICK_DIR="$HOME/.homesick/repos/homeshick"
        fi

        # Only check for updates every hour
        export HOMEBREW_AUTO_UPDATE_SECS=3600

        # Use a check instead of a beer 🍺
        export HOMEBREW_INSTALL_BADGE="✅  "

        # brew upgrade always assumes --cleanup has been passed
        export HOMEBREW_UPGRADE_CLEANUP="YES"

        # Install screensavers system-wide
        export HOMEBREW_CASK_OPTS="--screen_saverdir=/Library/Screen\ Savers/"

        ;;

    *:Linux:*:*)

        HOMESHICK_DIR="$HOME/.homesick/repos/homeshick"

        ;;

esac
