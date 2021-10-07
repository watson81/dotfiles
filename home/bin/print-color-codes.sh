#!/usr/bin/env bash

SAMPLE=""
[ -n "$1" ] && SAMPLE=":$1"

printf "To set formatting:\n\tprintf \"%s\"\n" "\e[CODEm"

printf "BG  \tFG Standard             \tFG Bold\n"
for bg in {0..7}; do
    printf "\e[0;4${bg}m%s :\t" "4${bg}"
    for fg in {0..7}; do
        printf "\e[3${fg}m%s" "3${fg}${SAMPLE} "
    done
    printf "\t\e[1;4${bg}m"

    for fg in {0..7}; do
        printf "\e[3${fg}m%s" "3${fg}${SAMPLE} "
    done
    printf "\e[0m\n"
done

printf "\nCode 0 clears formatting."
printf "\nCode 1 adds a \e[1m%s\e[0m effect." "bold"
[ -n "$1" ] && printf " Ex: \e[1m%s\e[0m" "${1}"
printf "\nCode 4 adds an \e[4m%s\e[0m effect." "underline"
[ -n "$1" ] && printf " Ex: \e[4m%s\e[0m" "${1}"
printf "\n"
