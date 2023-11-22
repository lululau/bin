#!/bin/bash

if [ -z "$HOMEBREW_PREFIX" ]; then
  if [ -e "/opt/homebrew/bin/brew" ]; then
    HOMEBREW_PREFIX="/opt/homebrew"
  else
    HOMEBREW_PREFIX="/usr/local"
  fi
fi



if echo "$1" | grep -q '^[$~/]'; then
  file=$1
elif echo "$1" | grep -q "^[a-z]\+://"
then
  file=$1
else
  iterm2_pwd=$(cat /tmp/iterm2_pwd)
  if [ -n "$iterm2_pwd" ]; then
    file=$iterm2_pwd/$1
  else
    file=~$1
  fi
fi

if echo "$file" | grep -q '\(\.rb$\)\|\(.rake$\)\|\(Gemfile\)' && [ -n "$2" ]
then
    open -a Emacs
    $HOMEBREW_PREFIX/bin/emacsclient -n +"$2" "$file"
else
    open "$file"
fi
