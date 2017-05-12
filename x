#!/bin/bash

if [ "$(uname)" = Darwin ]; then
    if [ -n "$1" ]; then
        emacsclient -t -s term "$@"
    else
        emacsclient -t -s term .
    fi
else
    if [ -n "$1" ]; then
        emacsclient -t "$@"
    else
        emacsclient -t .
    fi
fi
