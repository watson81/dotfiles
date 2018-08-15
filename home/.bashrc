#!/usr/bin/env bash
# This file is used for bash interactive settings

# powerline or custom
PROMPT_TYPE="CUSTOM"

# if custom: YES or NO
WANT_EMOJI="YES"


function _commandExists() {
    hash "$@" 2>/dev/null
}

_commandExists brew && [[ -f $(brew --prefix)/etc/bash_completion ]] && . $(brew --prefix)/etc/bash_completion

if [[ "$PROMPT_TYPE" == "CUSTOM" ]]; then
    [[ -f ~/.bash_prompt ]] && source ~/.bash_prompt
elif [[ "$PROMPT_TYPE" == "POWERLINE" ]]; then
    if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
        PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
    fi
elif [ -f /usr/local/share/liquidprompt ]; then
    . /usr/local/share/liquidprompt
fi

function _update_ps1() {
    PS1=$(powerline-shell $?)
}

# Leave ls alone. -G enables colors
#alias ls='ls -G'

# color, long, human-readable sizes
alias ll='ls -Glh'

alias sha1sum='shasum'
alias sha224sum='shasum -a 224'
alias sha256sum='shasum -a 256'
alias sha384sum='shasum -a 384'
alias sha512sum='shasum -a 512'
