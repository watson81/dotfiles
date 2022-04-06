#!/usr/bin/env bash

FONT_URLS=(
    'Meslo LG S Bold Italic Nerd Font Complete Mono.ttf' 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/S/Bold-Italic/complete/Meslo%20LG%20S%20Bold%20Italic%20Nerd%20Font%20Complete%20Mono.ttf'
    'Meslo LG S Bold Nerd Font Complete Mono.ttf' 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/S/Bold/complete/Meslo%20LG%20S%20Bold%20Nerd%20Font%20Complete%20Mono.ttf'
    'Meslo LG S Italic Nerd Font Complete Mono.ttf' 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/S/Italic/complete/Meslo%20LG%20S%20Italic%20Nerd%20Font%20Complete%20Mono.ttf'
    'Meslo LG S Regular Nerd Font Complete Mono.ttf' 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/S/Regular/complete/Meslo%20LG%20S%20Regular%20Nerd%20Font%20Complete%20Mono.ttf'
)

echoError() {
    printf "[\e[1;31mERROR\e[0m] %s\n" "$*" >&2
    exit 1
}

echoInfo() {
    printf "[\e[36mINFO\e[0m] %s\n" "$*" >&2
}

echoSuccess() {
    printf "[\e[32mSUCCESS\e[0m] %s\n" "$*" >&2
}

cleanupTempDir() {
    [[ -n "${NERD_FONT_INSTALL_TEMP_DIR}" ]] && rm -r "${NERD_FONT_INSTALL_TEMP_DIR}"
    unset NERD_FONT_INSTALL_TEMP_DIR
    echoInfo "Cleaned up ${NERD_FONT_INSTALL_TEMP_DIR}"
}

makeTempDir() {
    NERD_FONT_INSTALL_TEMP_DIR="$(mktemp -d -t nerd-font-installer-XXXXXX)" || echoError "Could not create temporary directory"
    trap cleanupTempDir EXIT
    echoInfo "Made ${NERD_FONT_INSTALL_TEMP_DIR}"
}

installViaCurl() {
    echoInfo "Installing via Curl"

    [[ ! -e "${INSTALL_DIR}" ]] && { mkdir -p "${INSTALL_DIR}" || echoError "Cannot create ${INSTALL_DIR}" ; }
    { [[ ! -d "${INSTALL_DIR}" ]] || [[ ! -w "${INSTALL_DIR}" ]] ; } && echoError "${INSTALL_DIR} is not a directory or is not writable"

    makeTempDir

    local i=0
    while [[ -n "${FONT_URLS[$i]}" ]]
    do
        if ! curl --silent --show-error --fail --location --output "${NERD_FONT_INSTALL_TEMP_DIR}/${FONT_URLS[$i]}" "${FONT_URLS[$((i+1))]}" ; then
            echoError "Failed to download ${FONT_URLS[$i]}"
        fi
        i=$((i+2))
    done

    i=0
    while [[ -n "${FONT_URLS[$i]}" ]]
    do
        cp "${NERD_FONT_INSTALL_TEMP_DIR}/${FONT_URLS[$i]}" "${INSTALL_DIR}/"
        i=$((i+2))
    done

    cleanupTempDir

    echoSuccess "Installed to ${INSTALL_DIR}"
}

installViaBrew() {
    if ! brew tap | grep '^homebrew/cask-fonts$' > /dev/null 2>&1 ; then
        echoInfo "Adding homebrew/cask-fonts to brew."
        if ! brew tap homebrew/cask-fonts ; then
            return 1
        fi
    fi
    echoInfo "Installing via brew"
    brew install --cask font-meslo-s-nerd-font
}

case "$(uname -s)" in
    Darwin)
        INSTALL_DIR="${HOME}/Library/Fonts"
        if hash brew > /dev/null 2>&1 ; then
            installViaBrew && exit
        fi

        # if brew doesn't work
        installViaCurl
        ;;
    Linux)
        INSTALL_DIR="${HOME}/.local/share/fonts"
        installViaCurl
        ;;
    *)
        echoError "I don't know how to install Nerd Fonts on this system."
        ;;
esac
