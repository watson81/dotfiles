#!/usr/bin/env bash
# This file is used for bash interactive settings

# powerline or custom
#PROMPT_TYPE="CUSTOM"

# if custom: YES or NO
WANT_EMOJI="YES"

#
# END USER CONFIGURATION
#

if [ -z "${PROFILE_SOURCED}" ]; then
    source ~/.profile
fi

export LS_OPTIONS

function _commandExists() {
    hash "$@" 2>/dev/null
}

function serve_via_http {
   PORT=${@:-8000}
   echo Serving $(pwd)

   if _commandExists python3 && python3 -c "import http.server" &>/dev/null; then
      python3 -m http.server ${PORT}
   elif _commandExists python2 && python2 -c "import SimpleHTTPServer" &>/dev/null; then
      python2 -m SimpleHTTPServer ${PORT}
   else
      echo "No python interpreter with an appropriate server module found."
   fi
}

case "$UNAME_MACHINE:$UNAME_SYSTEM:$UNAME_RELEASE:$UNAME_VERSION" in
    *:Darwin:*:*)
        if _commandExists brew && [ -r $(brew --prefix)/etc/bash_completion ]; then
            . $(brew --prefix)/etc/bash_completion
        fi

        if _commandExists box ; then
            box autocomplete --refresh-cache >/dev/null 2>&1
            BOX_AC_BASH_SETUP_PATH=~/Library/Caches/@box/cli/autocomplete/bash_setup && test -f $BOX_AC_BASH_SETUP_PATH && source $BOX_AC_BASH_SETUP_PATH;
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

if _commandExists keybase; then
    # Literal tabs in the following line must be preserved
    declare -r _KEYBASE_GLOBAL_OPTS="$(keybase h advanced | sed -e "1,$(keybase h advanced | grep -n "GLOBAL OPTIONS:" | cut -f1 -d:)d" -e 's/	\{1,\}.*//' -e 's/ *\(-[^ ,	]\{1,\}\)\( "[^"]*"\)\{0,\}/\1/g' | tr ',' '\n')"
    declare -r _KEYBASE_EXTRA_HELP_TOPICS="advanced gpg keyring tor"

    function _keybase_completion {
        local COMMAND="${1}"
        local CURRENT_WORD="${2}"
        local PREV_WORD="${3}"
        local -a VERBS=()

        if [ ${COMP_CWORD} -gt 1 ]; then
            # skip the command name and the word we're trying to complete
            for WORD in "${COMP_WORDS[@]:1:$(expr ${COMP_CWORD} - 1)}"; do
                if [[ ! "${WORD}" == -* ]]; then
                    VERBS+=("${WORD}")
                fi
            done
        fi

        local SEARCH_SPACE="$(keybase ${VERBS[@]} --generate-bash-completion)"
        if [[ ! "${SEARCH_SPACE}" == No\ help\ topic\ for\ * ]]; then
            if [ "${#VERBS[@]}" -lt 1 ]; then
                SEARCH_SPACE="${_KEYBASE_GLOBAL_OPTS}${SEARCH_SPACE}"
            elif [ "${VERBS[0]}" = "help" ] || [ "${VERBS[0]}" = "h" ]; then
                SEARCH_SPACE="$(keybase --generate-bash-completion) ${_KEYBASE_EXTRA_HELP_TOPICS}"
            else
                # even though it doesn't say it, help is always available
                SEARCH_SPACE="${SEARCH_SPACE} -h --help"
            fi
            COMPREPLY=($(compgen -W "${SEARCH_SPACE}" -- "${CURRENT_WORD}"))
        fi
    }

    complete -o "default" -F _keybase_completion keybase
fi

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
        . "$HOMESHICK_DIR/completions/homeshick-completion.bash"
    fi
fi
