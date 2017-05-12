#!/bin/bash

if [ -n "$EMACS" ]; then
    emacsclient -q --eval "(other-window 1)" &> /dev/null
fi

if [ -n "$1" ]; then
    emacsclient -n "$@"
else
    emacsclient -n .
fi
