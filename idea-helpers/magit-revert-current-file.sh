#!/bin/zsh

~/bin/idea-helpers/emacsclient-for-idea.sh "$@"
emacsclient -q --eval "(progn (find-file \"$2\") (magit-file-checkout (magit-get-current-branch) (buffer-file-name)))" &> /dev/null
