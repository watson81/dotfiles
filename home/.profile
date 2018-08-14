#!/bin/sh
# This file is read by any shell and should contain generic environment variable settings
export HOMESHICK_DIR="$(brew --prefix)/opt/homeshick"
. "$(brew --prefix)/opt/homeshick/homeshick.sh"

PATH=${PATH}:~/bin

# Only check for updates every hour
export HOMEBREW_AUTO_UPDATE_SECS=3600

# Use a check instead of a beer 🍺
export HOMEBREW_INSTALL_BADGE="✅  "

# brew upgrade always assumes --cleanup has been passed
export HOMEBREW_UPGRADE_CLEANUP="YES"

[ -d "$(brew --prefix)/opt/openssl/bin" ] && PATH="$(brew --prefix)/opt/openssl/bin":$PATH
