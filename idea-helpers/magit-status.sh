#!/usr/bin/env zsh

~/bin/idea-helpers/emacsclient-for-idea.sh "$@"
emacsclient -q --eval "(magit-status)" &> /dev/null
