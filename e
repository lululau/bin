#!/bin/bash

if [ -n "$INSIDE_EMACS" ]; then
    emacsclient -q --eval "(other-window 1)" &> /dev/null
fi

if [ $(uname) = Darwin ]; then
  if [ -n "$1" ]; then
      emacsclient -n "$@"
  else
      emacsclient -n .
  fi
else
  if [ -n "$1" ]; then
    emacsclient -t "$@"
  else
    emacsclient -t .
  fi
fi
