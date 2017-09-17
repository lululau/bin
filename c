#!/bin/zsh

tmpfile=$(mktemp)
tmux capture-pane -pS - > "$tmpfile"
if [ "$(uname)" = Darwin ]; then
   emacsclient -t -s term -e "(progn (find-file \"$tmpfile\") (linum-mode) (end-of-buffer))"
else
   emacsclient -t -e "(progn (find-file \"$tmpfile\") (linum-mode) (end-of-buffer))"
fi

rm "$tmpfile"
