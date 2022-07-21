#!/usr/bin/env zsh
# This file is used for zsh interactive settings

# Note: Unlike Bash, zsh properly source zshrc during creation of a login
# shell, so we have no need for .zprofile

# Load .profile when starting a non-login shell
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
        # -G enables colors
        LS_OPTIONS='-G'
    ;;

    *:Linux:*:*)
        LS_OPTIONS='--color=auto'

        eval "`dircolors`"
    ;;

esac

# See https://github.com/nvbn/thefuck
# re-executes failted commands with corrections
if _commandExists thefuck ; then
    eval $(thefuck --alias)
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
fi

# include additional machine-specific configuration
if [ -f "$HOME/.zshrc-$HOSTNAME_SHORT" ]; then
    . "$HOME/.zshrc-$HOSTNAME_SHORT"
fi

# Only load liquidprompt in interactive shells, not from a script or from scp
echo $- | grep -q i 2>/dev/null && . /usr/share/liquidprompt/liquidprompt
