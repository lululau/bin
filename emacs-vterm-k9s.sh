#!/bin/bash

if [ -z "$HOMEBREW_PREFIX" ]; then
  if [ -e "/opt/homebrew/bin/brew" ]; then
    HOMEBREW_PREFIX="/opt/homebrew"
  else
    HOMEBREW_PREFIX="/usr/local"
  fi
fi

open -a Emacs
$HOMEBREW_PREFIX/bin/emacsclient -q --eval '(progn (spacemacs/persp-switch-to-1) (delete-other-windows) (lx/run-in-vterm "~/bin/k9s" "*k9s*" nil t))' > /dev/null 2>&1 &
