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
        _commandExists brew && [[ -f $(brew --prefix)/etc/bash_completion ]] && . $(brew --prefix)/etc/bash_completion

        LIQUID_PROMPT=/usr/local/share/liquidprompt

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
    [ -r "$HOMESHICK_DIR/completions/homeshick-completion.bash" ] && . "$HOMESHICK_DIR/completions/homeshick-completion.bash"
fi

