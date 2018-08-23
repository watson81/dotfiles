#!/usr/bin/env bash
# This file is used for bash interactive settings

# powerline or custom
PROMPT_TYPE="CUSTOM"

# if custom: YES or NO
WANT_EMOJI="YES"

#
# END USER CONFIGURATION
#

LIQUID_PROMPT=/usr/local/share/liquidprompt

function _commandExists() {
    hash "$@" 2>/dev/null
}

_commandExists brew && [[ -f $(brew --prefix)/etc/bash_completion ]] && . $(brew --prefix)/etc/bash_completion

# Set up the prompt
if [ -r ~/.bash_prompt ] && ( [ "$PROMPT_TYPE" == "CUSTOM" ] || [ ! -r $LIQUID_PROMPT ] ); then
    . ~/.bash_prompt
elif [ -r $LIQUID_PROMPT ]; then
    . $LIQUID_PROMPT
fi

# Leave ls alone. -G enables colors
#alias ls='ls -G'

# color, long, human-readable sizes
alias ll='ls -Glh'

alias sha1sum='shasum'
alias sha224sum='shasum -a 224'
alias sha256sum='shasum -a 256'
alias sha384sum='shasum -a 384'
alias sha512sum='shasum -a 512'
