#!/bin/bash

if [ "$(uname)" = Darwin ]; then
    if [ "$(is_inside_emacs)" = true ]; then
      emacsclient -q --eval "(split-window)" &> /dev/null
      if [ -n "$1" ]; then
        emacsclient -n "$@"
      else
        emacsclient -n .
      fi
    else
      if [ -n "$1" ]; then
        emacsclient -t -s term "$@"
      else
        emacsclient -t -s term .
      fi
    fi
else
    if [ -n "$1" ]; then
        emacsclient -t "$@"
    else
        emacsclient -t .
    fi
fi
