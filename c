#!/bin/zsh

tmpfile=$(mktemp)
basename=$(basename "$tmpfile")
tmux capture-pane -pS - | perl -00 -pe 1 > "$tmpfile"
if [ "$(uname)" = Darwin ]; then
   emacsclient -t -s term -e "(progn (find-file \"$tmpfile\") (linum-mode) (end-of-buffer))"
   emacsclient -n -s term -e "(kill-buffer \"$basename\")"
else
   emacsclient -t -e "(progn (find-file \"$tmpfile\") (linum-mode) (end-of-buffer))"
   emacsclient -n -e "(kill-buffer \"$basename\")"
fi

rm "$tmpfile"
