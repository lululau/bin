#!/bin/zsh

~/bin/idea-helpers/emacsclient-for-idea.sh "$@"
emacsclient -q --eval "(progn (find-file \"$2\") (magit-diff-buffer-file))" &> /dev/null
