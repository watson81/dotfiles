#!/usr/bin/env bash
# This file is used for bash interactive settings

# Prompt will use Liquidprompt, Starship, or Custom in that order based on availability
# Override this by setting PROMPT_TYPE to one of those values

#
# END USER CONFIGURATION
#

if [ -z "${PROFILE_SOURCED}" ]; then
    source "${HOME}/.profile"
fi

function _commandExists() {
    hash "$@" 2>/dev/null
}

function serve_via_http {
   PORT="${*:-8000}"
   echo "Serving $(pwd)"

   if _commandExists python3 && python3 -c "import http.server" &>/dev/null; then
      python3 -m http.server "${PORT}"
   elif _commandExists python2 && python2 -c "import SimpleHTTPServer" &>/dev/null; then
      python2 -m SimpleHTTPServer "${PORT}"
   else
      echo "No python interpreter with an appropriate server module found."
   fi
}

# Defined in OS-specific section below
export LS_OPTIONS

case "$UNAME_MACHINE:$UNAME_SYSTEM:$UNAME_RELEASE:$UNAME_VERSION" in
    *:Darwin:*:*)
        if _commandExists brew ; then
            BREW_PREFIX="$(brew --prefix)"
            if [[ -r "${BREW_PREFIX}/etc/bash_completion" ]] ; then
                source "${BREW_PREFIX}/etc/bash_completion"
            elif [[ -r "${BREW_PREFIX}/etc/profile.d/bash_completion.sh" ]] ; then
                source "${BREW_PREFIX}/etc/profile.d/bash_completion.sh"
            else
                for COMPLETION_FILE in "${BREW_PREFIX}/etc/bash_completion.d/"* ; do
                    [[ -r "$COMPLETION_FILE" ]] && source "${COMPLETION_FILE}"
                done
            fi
            unset BREW_PREFIX
        fi

        if _commandExists box ; then
            box autocomplete --refresh-cache >/dev/null 2>&1
            BOX_AC_BASH_SETUP_PATH="${HOME}/Library/Caches/@box/cli/autocomplete/bash_setup"
            [[ -f "${BOX_AC_BASH_SETUP_PATH}" ]] && source "${BOX_AC_BASH_SETUP_PATH}"
            unset BOX_AC_BASH_SETUP_PATH
        fi

        # -G enables colors
        LS_OPTIONS='-G'

        # Otherwise GPG's pinentry can't figure out where to prompt
        GPG_TTY=$(tty)
        export GPG_TTY
    ;;

    *:Linux:*:*)
        LS_OPTIONS='--color=auto'

        eval "$(dircolors)"
    ;;

esac

if _commandExists keybase; then
    _KEYBASE_GLOBAL_OPTS="$(keybase h advanced | sed -e "1,$(keybase h advanced | grep -n "GLOBAL OPTIONS:" | cut -f1 -d:)d" -e 's/	\{1,\}.*//' -e 's/ *\(-[^ ,	]\{1,\}\)\( "[^"]*"\)\{0,\}/\1/g' | tr ',' '\n')"
    # Literal tabs in the previous line must be preserved.                                                                    here ^                  and here ^
    _KEYBASE_EXTRA_HELP_TOPICS="advanced gpg keyring tor"
    readonly _KEYBASE_GLOBAL_OPTS _KEYBASE_EXTRA_HELP_TOPICS

    function _keybase_completion {
        # parameters: $1 = command whose arguments are being completed, $2 = current word being completed, $3 = previous word
        local CURRENT_WORD="${2}"
        local -a VERBS=()

        if [[ ${COMP_CWORD} -gt 1 ]]; then
            # skip the command name and the word we're trying to complete
            for WORD in "${COMP_WORDS[@]:1:$((COMP_CWORD - 1))}"; do
                if [[ ! "${WORD}" == -* ]]; then
                    VERBS+=("${WORD}")
                fi
            done
        fi

        local SEARCH_SPACE
        SEARCH_SPACE="$(keybase "${VERBS[@]}" --generate-bash-completion)"
        if [[ ! "${SEARCH_SPACE}" == No\ help\ topic\ for\ * ]]; then
            if [ "${#VERBS[@]}" -lt 1 ]; then
                SEARCH_SPACE="${_KEYBASE_GLOBAL_OPTS}${SEARCH_SPACE}"
            elif [ "${VERBS[0]}" = "help" ] || [ "${VERBS[0]}" = "h" ]; then
                SEARCH_SPACE="$(keybase --generate-bash-completion) ${_KEYBASE_EXTRA_HELP_TOPICS}"
            else
                # even though it doesn't say it, help is always available
                SEARCH_SPACE="${SEARCH_SPACE} -h --help"
            fi
            # shellcheck disable=SC2207 # Shellcheck doesn't like array generation from commands
            COMPREPLY=($(compgen -W "${SEARCH_SPACE}" -- "${CURRENT_WORD}"))
        fi
    }

    complete -o "default" -F _keybase_completion keybase
fi

# See https://github.com/nvbn/thefuck
# re-executes failed commands with corrections
if _commandExists thefuck ; then
    eval "$(thefuck --alias)"
fi

# Set up Bash History Control; options are a colon seperated list of:
#   ignorespace = ignore commands starting with spaces
#   ignoredups = ignore duplicated BACK TO BACK commands (e.g running ls immediately followed by ls again)
#   ignoreboth = do both of the above
#   erasedups  = ignore duplicated commands no matter where they appear in the history
HISTCONTROL="ignoreboth:erasedups"
HISTIGNORE="exit:ls:ll:pwd:clear:history"

# Set up the prompt
if [ -r "${HOME}/.homesick/repos/liquidprompt/liquidprompt" ]; then
    LIQUID_PROMPT="${HOME}/.homesick/repos/liquidprompt/liquidprompt"
elif [ -r "/usr/local/share/liquidprompt" ]; then
    LIQUID_PROMPT="/usr/local/share/liquidprompt"
fi

if [ -z "${PROMPT_TYPE}" ]; then
    if   _commandExists starship ;      then PROMPT_TYPE="Starship"
    elif [ -n "${LIQUID_PROMPT}" ];     then PROMPT_TYPE="Liquidprompt"
    elif [ -r "${HOME}/.bash_prompt" ]; then PROMPT_TYPE="Custom"
    fi
fi

case "${PROMPT_TYPE,,}" in
    custom)         source "${HOME}/.bash_prompt"           || echo "ERROR: Custom prompt derped" ;;
    liquidprompt)   source "${LIQUID_PROMPT}"               || echo "ERROR: Liquidprompt spilled" ;;
    starship)       eval   "false || $(starship init bash)" || echo "ERROR: Starship failed to launch" ;;
esac

alias ls='ls ${LS_OPTIONS}'
alias ll='ls ${LS_OPTIONS} -lh'
alias l='ls ${LS_OPTIONS} -lA'

if _commandExists shasum ; then
    alias sha1sum='shasum'
    alias sha224sum='shasum -a 224'
    alias sha256sum='shasum -a 256'
    alias sha384sum='shasum -a 384'
    alias sha512sum='shasum -a 512'
fi

alias date-iso='date +%FT%T%z'
alias date_iso='date +%FT%T%z | tr : _'

if [ -r "${HOMESHICK_DIR}/homeshick.sh" ]; then
    . "${HOMESHICK_DIR}/homeshick.sh"
    if [ -r "${HOMESHICK_DIR}/completions/homeshick-completion.bash" ]; then
        . "${HOMESHICK_DIR}/completions/homeshick-completion.bash"
    fi
fi

if [ -r "${HOME}/.aws/credentials" ]; then
    export AWS_SHARED_CREDENTIALS_FILE="${HOME}/.aws/credentials"
    export AWS_DEFAULT_REGION="us-east-1"
fi
[ -r "${HOME}/.bashrc-aws-roles" ] && "${HOME}/.bashrc-aws-roles"

# include additional machine-specific configuration
if [ -f "${HOME}/.bashrc-${HOSTNAME_SHORT}" ]; then
    source "${HOME}/.bashrc-${HOSTNAME_SHORT}"
fi
