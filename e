#!/bin/bash

function is_inside_emacs() {
  if [ -n "$TMUX" ]; then
    local client_tty="$(tmux display-message -p '#{client_tty}')"
    if lsof "$client_tty" | grep -q Emacs; then
      echo true
    else
      echo false
    fi
  else
    [ -n "$INSIDE_EMACS" ] && echo true || echo false
  fi
}

if [ "$(is_inside_emacs)" = true ]; then
    emacsclient -q --eval "(split-window)" &> /dev/null
fi

if [ $(uname) = Darwin ]; then
  open -a Emacs
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
