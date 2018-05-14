#!/usr/bin/env zsh

~/bin/idea-helpers/emacsclient-for-idea.sh "$@"
emacsclient -q --eval "(progn (find-file \"$2\") (spacemacs/git-blame-micro-state))" &> /dev/null
