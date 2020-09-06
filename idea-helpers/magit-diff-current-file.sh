#!/usr/bin/env zsh

open -a Emacs
~/bin/idea-helpers/emacsclient-for-idea.sh "$@"
emacsclient -q --eval "(progn (find-file \"$2\") (magit-diff-buffer-file))" &> /dev/null
