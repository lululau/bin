#!/usr/bin/env zsh

open -a Emacs
~/bin/idea-helpers/emacsclient-for-idea.sh "$@"
emacsclient -q --eval "(magit-status)" &> /dev/null
