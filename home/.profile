#!/bin/sh
# This file is read by any shell and should contain generic environment variable settings

PATH=${PATH}:~/bin

# Figure out what OS this is being run on
# Inspired by GNU's config.guess from the config project (http://savannah.gnu.org/projects/config/)
UNAME_MACHINE=`(uname -m) 2>/dev/null` || UNAME_MACHINE=unknown
UNAME_RELEASE=`(uname -r) 2>/dev/null` || UNAME_RELEASE=unknown
UNAME_SYSTEM=`(uname -s) 2>/dev/null`  || UNAME_SYSTEM=unknown
UNAME_VERSION=`(uname -v) 2>/dev/null` || UNAME_VERSION=unknown

# Tell Microsoft to stop spying on me
export DOTNET_CLI_TELEMETRY_OPTOUT=true

export HOMESHICK_DIR

function TryAddToPath {
    if [ -d "$1" ]; then
        PATH="$1":$PATH
    fi
}

case "$UNAME_MACHINE:$UNAME_SYSTEM:$UNAME_RELEASE:$UNAME_VERSION" in
    *:Darwin:*:*)
        UNAME_PROCESSOR=`uname -p` || UNAME_PROCESSOR=unknown

        function HasBrew {
            command -v brew >/dev/null
        }
        function TryAddBrewPaths {
            PREFIX=""
            if HasBrew; then
                PREFIX="$(brew --prefix)"
            fi

            for d in "$@"
            do
                TryAddToPath "${PREFIX}$d"
            done
        }

        if HasBrew; then
            HOMESHICK_DIR="$(brew --prefix)/opt/homeshick"

            TryAddBrewPaths "/opt/openssl/bin" \
                            "/opt/zip/bin" \
                            "/opt/unzip/bin" \
                            "/opt/bzip2/bin"
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

unset -f TryAddToPath
unset -f HasBrew
unset -f TryAddBrewPaths