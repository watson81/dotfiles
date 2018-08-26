#!/usr/bin/env bash
# This file is used for bash interactive settings

# powerline or custom
PROMPT_TYPE="CUSTOM"

# if custom: YES or NO
WANT_EMOJI="YES"

#
# END USER CONFIGURATION
#

export LS_OPTIONS

function _commandExists() {
    hash "$@" 2>/dev/null
}

case "$UNAME_MACHINE:$UNAME_SYSTEM:$UNAME_RELEASE:$UNAME_VERSION" in
    *:Darwin:*:*)
        if _commandExists brew && [ -r $(brew --prefix)/etc/bash_completion ]; then
            . $(brew --prefix)/etc/bash_completion
        fi

        if [ -r "$HOME/.homesick/repos/liquidprompt/liquidprompt" ]; then
            LIQUID_PROMPT="$HOME/.homesick/repos/liquidprompt/liquidprompt"
        else
            LIQUID_PROMPT=/usr/local/share/liquidprompt
        fi

        # -G enables colors
        LS_OPTIONS='-G'
    ;;

    *:Linux:*:*)
        LS_OPTIONS='--color=auto'

        LIQUID_PROMPT=$HOME/.homesick/repos/liquidprompt/liquidprompt

        eval "`dircolors`"
    ;;

esac

# Set up the prompt
if [ -r ~/.bash_prompt ] && ( [ "$PROMPT_TYPE" == "CUSTOM" ] || [ ! -r $LIQUID_PROMPT ] ); then
    . ~/.bash_prompt
elif [ -r $LIQUID_PROMPT ]; then
    . $LIQUID_PROMPT
fi

alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -lh'
alias l='ls $LS_OPTIONS -lA'

alias sha1sum='shasum'
alias sha224sum='shasum -a 224'
alias sha256sum='shasum -a 256'
alias sha384sum='shasum -a 384'
alias sha512sum='shasum -a 512'

if [ -r "$HOMESHICK_DIR/homeshick.sh" ]; then
    . "$HOMESHICK_DIR/homeshick.sh"
    if [ -r "$HOMESHICK_DIR/completions/homeshick-completion.bash" ]; then
        "$HOMESHICK_DIR/completions/homeshick-completion.bash"
    fi
fi
