#!/usr/bin/env bash
source ~/.profile

# Unlike most shells, Bash login shells do not automaticall source .bashrc
if [[ $- == *i* ]]; then
    source ~/.bashrc
fi
