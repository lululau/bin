#!/bin/bash

if [ -z "$HOMEBREW_PREFIX" ]; then
  if [ -e "/opt/homebrew/bin/brew" ]; then
    HOMEBREW_PREFIX="/opt/homebrew"
  else
    HOMEBREW_PREFIX="/usr/local"
  fi
fi



open -a Emacs
$HOMEBREW_PREFIX/bin/emacsclient -q --eval "(call-interactively 'lx/open-mail-custom-layout-or-mu4e-main)" > /dev/null 2>&1 &
